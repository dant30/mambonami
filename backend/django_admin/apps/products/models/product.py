# django_admin/apps/products/models/product.py
# backend/django_admin/apps/products/models/product.py
from django.db import models
from django.core.validators import MinValueValidator
from shared.db_models.base import BaseModel
from apps.users.models import FarmerProfile
from .category import ProductCategory

class Product(BaseModel):
    """Product listing by a farmer."""
    farmer = models.ForeignKey(FarmerProfile, on_delete=models.CASCADE, related_name='products')
    category = models.ForeignKey(ProductCategory, on_delete=models.PROTECT, related_name='products')
    name = models.CharField(max_length=100, help_text="Product name (e.g., 'Mango - Ngowe')")
    variety = models.CharField(
        max_length=100,
        blank=True,
        help_text="e.g., Roma, Cherry, Heirloom, Ngowe, Apple mango"
    )
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0.01)])
    available_quantity = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0)])
    unit = models.CharField(max_length=20, help_text="kg, piece, litre, tray, bunch")
    harvest_date = models.DateField(help_text="Date when product was harvested/packed")
    shelf_life_days = models.PositiveIntegerField(default=3, help_text="Remaining shelf life in days")
    is_active = models.BooleanField(default=True, help_text="Visible for purchase")
    # Optional: image, description, organic flag, etc.
    image = models.ImageField(upload_to='products/', blank=True, null=True)
    description = models.TextField(blank=True)
    
    # Pickup location (GPS)
    pickup_lat = models.DecimalField(
        max_digits=9, decimal_places=6,
        null=True, blank=True,
        help_text="Latitude of harvest/pickup location"
    )
    pickup_lng = models.DecimalField(
        max_digits=9, decimal_places=6,
        null=True, blank=True,
        help_text="Longitude of harvest/pickup location"
    )

    class Meta:
        db_table = 'products'
        verbose_name = 'Product'
        verbose_name_plural = 'Products'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['farmer', 'is_active']),
            models.Index(fields=['category', 'is_active']),
            models.Index(fields=['harvest_date']),
        ]

    def __str__(self):
        title = self.name
        if self.variety:
            title = f"{self.name} ({self.variety})"
        return f"{title} - {self.farmer.user.phone} @ {self.price_per_unit}/{self.unit}"