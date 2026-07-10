# backend/django_admin/apps/products/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter
from ..models import Product, ProductCategory
from ..serializers import ProductSerializer, ProductCreateUpdateSerializer, ProductCategorySerializer
from ..services import list_active_products, create_product, update_product, delete_product
from apps.users.permissions import IsFarmer, IsAdmin

class ProductCategoryListView(generics.ListAPIView):
    queryset = ProductCategory.objects.filter(is_active=True)
    serializer_class = ProductCategorySerializer
    permission_classes = [permissions.AllowAny]

class ProductListView(generics.ListAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['category__code', 'farmer__user__phone', 'is_organic']
    ordering_fields = ['price_per_unit', 'harvest_date', 'created_at', 'rating']
    ordering = ['-created_at']

    def get_serializer_context(self):
        context = super().get_serializer_context()
        # Extract buyer GPS from query params (if passed)
        buyer_lat = self.request.query_params.get('lat')
        buyer_lng = self.request.query_params.get('lng')
        if buyer_lat and buyer_lng:
            try:
                context['buyer_lat'] = float(buyer_lat)
                context['buyer_lng'] = float(buyer_lng)
            except ValueError:
                pass
        return context

    def get_queryset(self):
        return list_active_products(self.request.query_params)

class ProductDetailView(generics.RetrieveAPIView):
    queryset = Product.objects.filter(is_active=True)
    serializer_class = ProductSerializer
    permission_classes = [permissions.AllowAny]
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

class FarmerProductListCreateView(generics.ListCreateAPIView):
    permission_classes = [permissions.IsAuthenticated, IsFarmer]
    parser_classes = [MultiPartParser, FormParser]

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return ProductCreateUpdateSerializer
        return ProductSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        # For farmer's own products, we may not need distance but keep for consistency
        return context

    def get_queryset(self):
        farmer_profile = self.request.user.farmer_profile
        return Product.objects.filter(farmer=farmer_profile)

    def perform_create(self, serializer):
        farmer_profile = self.request.user.farmer_profile
        create_product(farmer_profile, serializer.validated_data)

class FarmerProductUpdateDeleteView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [permissions.IsAuthenticated, IsFarmer]
    serializer_class = ProductCreateUpdateSerializer
    lookup_field = 'uuid'

    def get_queryset(self):
        return Product.objects.filter(farmer=self.request.user.farmer_profile)

    def perform_update(self, serializer):
        product = self.get_object()
        update_product(product, serializer.validated_data, self.request.user)

    def perform_destroy(self, instance):
        delete_product(instance, self.request.user)