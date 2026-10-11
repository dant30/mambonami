from django.shortcuts import get_object_or_404
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.users.permissions import IsAdmin

from ..models import Product
from ..serializers import ProductSerializer


class AdminProductListView(generics.ListAPIView):
    """List active and inactive product listings for administrators."""
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    serializer_class = ProductSerializer
    queryset = Product.objects.select_related('farmer__user', 'category').order_by('-created_at')


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