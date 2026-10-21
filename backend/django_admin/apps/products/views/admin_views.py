from django.shortcuts import get_object_or_404
from rest_framework import generics, permissions, status
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.users.permissions import IsAdmin

from ..models import Product
from ..serializers import ProductCreateUpdateSerializer, ProductSerializer
from ..services import update_product


class AdminProductListView(generics.ListAPIView):
    """List active and inactive product listings for administrators."""
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    serializer_class = ProductSerializer
    queryset = Product.objects.select_related('farmer__user', 'category').order_by('-created_at')


class AdminProductDetailView(generics.RetrieveUpdateAPIView):
    """View and update a product listing as an administrator."""
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    parser_classes = [JSONParser, MultiPartParser, FormParser]
    lookup_field = 'uuid'
    queryset = Product.objects.select_related('farmer__user', 'category').prefetch_related('bulk_price_tiers')

    def get_serializer_class(self):
        return ProductSerializer if self.request.method == 'GET' else ProductCreateUpdateSerializer

    def perform_update(self, serializer):
        update_product(serializer.instance, serializer.validated_data, self.request.user)


class AdminProductStatusView(APIView):
    """Activate or deactivate a product listing without exposing other fields."""
    permission_classes = [permissions.IsAuthenticated, IsAdmin]

    def post(self, request, uuid):
        is_active = request.data.get('is_active')
        if not isinstance(is_active, bool):
            return Response({'is_active': 'A boolean value is required.'}, status=status.HTTP_400_BAD_REQUEST)

        product = get_object_or_404(Product, uuid=uuid)
        product.is_active = is_active
        product.save(update_fields=['is_active', 'updated_at'])
        return Response(ProductSerializer(product, context={'request': request}).data, status=status.HTTP_200_OK)