# backend/django_admin/apps/products/models/__init__.py
from .category import ProductCategory
from .product import Product

__all__ = ['ProductCategory', 'Product']