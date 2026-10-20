# backend/django_admin/apps/products/services/product_service.py
from django.db import models, transaction
from django.core.exceptions import PermissionDenied
from apps.users.permissions import is_admin_user
from ..models import Product
from apps.users.models import FarmerProfile
from core.cache import RedisCache

def list_active_products(filters=None):
    """Return active products with optional filtering."""
    queryset = Product.objects.filter(is_active=True).select_related('farmer__user', 'category').prefetch_related('bulk_price_tiers')
    if filters:
        category_code = filters.get('category_code') or filters.get('category')
        if category_code:
            queryset = queryset.filter(category__code=category_code)
        if farmer_id := filters.get('farmer_id'):
            queryset = queryset.filter(farmer_id=farmer_id)
        if (min_price := filters.get('min_price')) not in (None, ''):
            queryset = queryset.filter(price_per_unit__gte=min_price)
        if (max_price := filters.get('max_price')) not in (None, ''):
            queryset = queryset.filter(price_per_unit__lte=max_price)
        if (min_rating := filters.get('min_rating')) not in (None, ''):
            queryset = queryset.filter(rating__gte=min_rating)
        if filters.get('in_stock') in (True, 'true', '1'):
            queryset = queryset.filter(available_quantity__gt=models.F('reserved_quantity'))
        search = filters.get('search')
        if search:
            queryset = queryset.filter(
                models.Q(name__icontains=search) |
                models.Q(variety__icontains=search) |
                models.Q(description__icontains=search)
            )
    return queryset

def create_product(farmer_profile: FarmerProfile, data: dict) -> Product:
    """Create a new product for a farmer (atomic)."""
    with transaction.atomic():
        product = Product.objects.create(farmer=farmer_profile, **data)
        # Invalidate cache for product list
        RedisCache.delete('product_list_cache')
        return product

def update_product(product: Product, data: dict, user) -> Product:
    """Update product if user is the owner or admin."""
    if product.farmer.user != user and not is_admin_user(user):
        raise PermissionDenied("You do not own this product.")
    with transaction.atomic():
        for key, value in data.items():
            setattr(product, key, value)
        product.save()
        RedisCache.delete(f'product_{product.id}')
        RedisCache.delete('product_list_cache')
        return product

def delete_product(product: Product, user) -> None:
    """Soft delete product (set is_active=False)."""
    if product.farmer.user != user and not is_admin_user(user):
        raise PermissionDenied("You do not own this product.")
    product.is_active = False
    product.save()
    RedisCache.delete(f'product_{product.id}')
    RedisCache.delete('product_list_cache')