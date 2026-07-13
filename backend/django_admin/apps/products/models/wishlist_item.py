# backend/django_admin/apps/products/models/wishlist_item.py
from django.db import models
from django.conf import settings
from shared.db_models.base import BaseModel


class WishlistItem(BaseModel):
    buyer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='wishlist')
    product = models.ForeignKey('products.Product', on_delete=models.CASCADE, related_name='wishlisted_by')

    class Meta:
        db_table = 'wishlist_items'
        unique_together = [('buyer', 'product')]

    def __str__(self):
        return f"WishlistItem {self.buyer} -> {self.product}"
