# backend/django_admin/apps/products/models/review.py
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.conf import settings
from shared.db_models.base import BaseModel


class ProductReview(BaseModel):
    product = models.ForeignKey('products.Product', on_delete=models.CASCADE, related_name='reviews')
    buyer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='product_reviews')
    order_item = models.OneToOneField('orders.OrderItem', on_delete=models.CASCADE, related_name='review')
    rating = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    comment = models.TextField(blank=True)

    class Meta:
        db_table = 'product_reviews'
        unique_together = [('product', 'buyer', 'order_item')]