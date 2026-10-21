# backend/django_admin/apps/products/views/api.py
from django.core.exceptions import ObjectDoesNotExist
from django.conf import settings
from django.db import models
from django.shortcuts import get_object_or_404
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import generics, permissions, status
from rest_framework.exceptions import ValidationError
from rest_framework.filters import OrderingFilter
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView

from apps.users.models import FarmerProfile
from apps.users.permissions import IsFarmer
from apps.logistics.services.geolocation import haversine

from ..models import Product, ProductCategory, ProductReview, WishlistItem
from ..serializers import (ProductCategorySerializer, ProductCreateUpdateSerializer,
                           ProductReviewSerializer, ProductSerializer, WishlistItemSerializer)
from ..services import create_product, delete_product, list_active_products, update_product


def _get_farmer_profile_for_user(user):
    if not getattr(user, 'is_authenticated', False):
        return None
    if getattr(user, 'role', None) != 'farmer':
        return None
    try:
        return user.farmer_profile
    except (AttributeError, ObjectDoesNotExist):
        return None


def _product_ids_within_delivery_radius(products, buyer_lat, buyer_lng):
    radius_km = float(settings.MAX_DELIVERY_DISTANCE_KM)
    valid_ids = []
    for product in products:
        if product.pickup_lat is None or product.pickup_lng is None:
            continue
        distance_km = haversine(
            buyer_lat,
            buyer_lng,
            float(product.pickup_lat),
            float(product.pickup_lng),
        )
        if distance_km <= radius_km:
            valid_ids.append(product.pk)
    return valid_ids

class ProductCategoryListView(generics.ListAPIView):
    queryset = ProductCategory.objects.filter(is_active=True)
    serializer_class = ProductCategorySerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'public_categories'


class ProductUnitListView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        return Response([
            {'code': code, 'name': name}
            for code, name in Product.UNIT_CHOICES
        ])


class ProductListView(generics.ListAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'public_products'
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['category__code', 'farmer__user__phone', 'is_organic']
    ordering_fields = ['price_per_unit', 'harvest_date', 'created_at', 'rating']
    ordering = ['-created_at']

    def get_serializer_context(self):
        context = super().get_serializer_context()
        # Extract buyer GPS from query params (if passed)
        buyer_lat = self.request.query_params.get('buyer_lat') or self.request.query_params.get('lat')
        buyer_lng = self.request.query_params.get('buyer_lng') or self.request.query_params.get('lng')
        if buyer_lat and buyer_lng:
            try:
                context['buyer_lat'] = float(buyer_lat)
                context['buyer_lng'] = float(buyer_lng)
            except ValueError:
                pass
        return context

    def get_queryset(self):
        queryset = list_active_products(self.request.query_params)
        buyer_lat = self.request.query_params.get('buyer_lat')
        buyer_lng = self.request.query_params.get('buyer_lng')
        if buyer_lat is None and buyer_lng is None:
            buyer_lat = self.request.query_params.get('lat')
            buyer_lng = self.request.query_params.get('lng')
        if buyer_lat is None and buyer_lng is None:
            return queryset
        if buyer_lat is None or buyer_lng is None:
            raise ValidationError({'detail': 'Provide both buyer_lat and buyer_lng to filter by delivery distance.'})
        try:
            latitude = float(buyer_lat)
            longitude = float(buyer_lng)
            if not -90 <= latitude <= 90 or not -180 <= longitude <= 180:
                raise ValueError('coordinates out of bounds')
        except (TypeError, ValueError):
            raise ValidationError({'detail': 'Buyer coordinates must be valid latitude and longitude values.'})

        candidates = queryset.filter(pickup_lat__isnull=False, pickup_lng__isnull=False).only(
            'id', 'pickup_lat', 'pickup_lng'
        ).iterator(chunk_size=500)
        product_ids = _product_ids_within_delivery_radius(candidates, latitude, longitude)
        return queryset.filter(pk__in=product_ids)

class ProductDetailView(generics.RetrieveAPIView):
    queryset = Product.objects.filter(is_active=True).select_related('farmer__user', 'category').prefetch_related('bulk_price_tiers')
    serializer_class = ProductSerializer
    permission_classes = [permissions.AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'public_product_detail'
    lookup_field = 'uuid'

    def get_serializer_context(self):
        context = super().get_serializer_context()
        # As above, optionally get buyer location from query
        buyer_lat = self.request.query_params.get('lat')
        buyer_lng = self.request.query_params.get('lng')
        if buyer_lat and buyer_lng:
            try:
                context['buyer_lat'] = float(buyer_lat)
                context['buyer_lng'] = float(buyer_lng)
            except ValueError:
                pass
        return context


class ProductReviewListCreateView(generics.ListCreateAPIView):
    serializer_class = ProductReviewSerializer

    def get_product(self):
        return get_object_or_404(Product, uuid=self.kwargs['uuid'], is_active=True)

    def get_permissions(self):
        if self.request.method == 'POST':
            return [permissions.IsAuthenticated()]
        return [permissions.AllowAny()]

    def get_queryset(self):
        return ProductReview.objects.filter(product=self.get_product()).select_related('buyer').order_by('-created_at')

    def get_serializer_context(self):
        return {**super().get_serializer_context(), 'product': self.get_product()}


class WishlistListView(generics.ListAPIView):
    serializer_class = WishlistItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return WishlistItem.objects.filter(buyer=self.request.user).select_related(
            'product', 'product__farmer', 'product__category'
        ).order_by('-created_at')


class WishlistItemView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, uuid):
        product = get_object_or_404(Product, uuid=uuid, is_active=True)
        item, created = WishlistItem.objects.get_or_create(
            buyer=request.user,
            product=product,
        )
        if created:
            Product.objects.filter(pk=product.pk).update(
                wishlist_count=product.wishlist_count + 1
            )
        return Response(
            WishlistItemSerializer(item, context={'request': request}).data,
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )

    def delete(self, request, uuid):
        item = WishlistItem.objects.filter(
            buyer=request.user,
            product__uuid=uuid,
        ).first()
        if item:
            item.delete()
            Product.objects.filter(uuid=uuid, wishlist_count__gt=0).update(
                wishlist_count=models.F('wishlist_count') - 1
            )
        return Response(status=status.HTTP_204_NO_CONTENT)

class FarmerProductListCreateView(generics.ListCreateAPIView):
    permission_classes = [permissions.IsAuthenticated, IsFarmer]
    parser_classes = [JSONParser, MultiPartParser, FormParser]

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return ProductCreateUpdateSerializer
        return ProductSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        # For farmer's own products, we may not need distance but keep for consistency
        return context

    def get_queryset(self):
        farmer_profile = _get_farmer_profile_for_user(self.request.user)
        if not farmer_profile:
            return Product.objects.none()
        return Product.objects.filter(farmer=farmer_profile)

    def perform_create(self, serializer):
        farmer_profile = _get_farmer_profile_for_user(self.request.user)
        if not farmer_profile:
            farmer_profile, _ = FarmerProfile.objects.get_or_create(
                user=self.request.user,
                defaults={'mpesa_number': self.request.user.phone},
            )
        if not farmer_profile:
            raise ValidationError({'detail': 'Farmer profile is not available for this account.'})
        create_product(farmer_profile, serializer.validated_data)

class FarmerProductUpdateDeleteView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [permissions.IsAuthenticated, IsFarmer]
    parser_classes = [JSONParser, MultiPartParser, FormParser]
    serializer_class = ProductCreateUpdateSerializer
    lookup_field = 'uuid'

    def get_queryset(self):
        farmer_profile = _get_farmer_profile_for_user(self.request.user)
        if not farmer_profile:
            return Product.objects.none()
        return Product.objects.filter(farmer=farmer_profile)

    def perform_update(self, serializer):
        product = self.get_object()
        update_product(product, serializer.validated_data, self.request.user)

    def perform_destroy(self, instance):
        delete_product(instance, self.request.user)