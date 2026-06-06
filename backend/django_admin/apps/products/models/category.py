# django_admin/apps/products/models/category.py
# backend/django_admin/apps/products/models/category.py
from django.db import models
from shared.db_models.base import BaseModel

class ProductCategory(BaseModel):
    """Product category (MA, MBO, NA, MI) with display name."""
    code = models.CharField(max_length=3, unique=True, help_text="Category code (MA, MBO, NA, MI)")
    name = models.CharField(max_length=50, help_text="Category name (Matunda, Mboga, etc.)")
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'product_categories'
        verbose_name = 'Product Category'
        verbose_name_plural = 'Product Categories'
        ordering = ['code']

    def __str__(self):
        return f"{self.code} - {self.name}"