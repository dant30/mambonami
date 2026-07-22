# backend/django_admin/apps/products/models/product.py
from django.db import models
from django.core.validators import MinValueValidator
from datetime import timedelta
from shared.db_models.base import BaseModel
from .category import ProductCategory

class Product(BaseModel):
    """Product listing by a farmer."""
    
    UNIT_CHOICES = [
        ('kg', 'Kilogram'),
        ('piece', 'Piece'),
        ('litre', 'Litre'),
        ('tray', 'Tray'),
        ('bunch', 'Bunch'),
        ('bag', 'Bag'),
        ('crate', 'Crate'),
        ('box', 'Box'),
    ]
    
    farmer = models.ForeignKey('users.FarmerProfile', on_delete=models.CASCADE, related_name='products')
    category = models.ForeignKey(ProductCategory, on_delete=models.PROTECT, related_name='products')
    sku = models.CharField(
        max_length=30,
        unique=True,
        blank=True,
        null=True,
        editable=False,
        help_text="Auto-generated product SKU (category code + numeric ID)"
    )
    name = models.CharField(max_length=100, help_text="Product name (e.g., 'Mango - Ngowe')")
    variety = models.CharField(
        max_length=100,
        blank=True,
        help_text="e.g., Roma, Cherry, Heirloom, Ngowe, Apple mango"
    )
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0.01)])
    available_quantity = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0)])
    min_stock_level = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
        validators=[MinValueValidator(0)],
        help_text="Minimum quantity threshold before low-stock alerts are raised"
    )
    reserved_quantity = models.DecimalField(
        max_digits=12, decimal_places=2, default=0,
        validators=[MinValueValidator(0)],
        help_text="Quantity reserved by buyers (in orders/carts)"
    )
    unit = models.CharField(
        max_length=20, 
        choices=UNIT_CHOICES,
        help_text="Unit of measurement"
    )
    weight_per_unit = models.DecimalField(
        max_digits=8, decimal_places=2, default=0,
        validators=[MinValueValidator(0)],
        help_text="Weight in kg for one unit (e.g., 0.5 for half kg, 2.0 for 2kg sack)"
    )
    harvest_date = models.DateField(help_text="Date when product was harvested/packed")
    shelf_life_days = models.PositiveIntegerField(default=3, help_text="Shelf life duration in days from harvest")
    expiry_date = models.DateField(
        null=True, blank=True,
        help_text="Calculated expiry date (harvest_date + shelf_life_days)"
    )
    is_organic = models.BooleanField(
        default=False,
        help_text="Mark as organic certified"
    )
    is_active = models.BooleanField(default=True, help_text="Visible for purchase")
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

    # ─── NEW FIELDS from gap analysis ────────────────────────────────────────
    rating = models.FloatField(
        default=5.0,
        help_text="Average buyer rating 1-5 (computed from product reviews)"
    )
    review_count = models.PositiveIntegerField(
        default=0,
        help_text="Total number of buyer reviews"
    )
    wishlist_count = models.PositiveIntegerField(
        default=0,
        help_text="Number of buyers who saved this product to wishlist"
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
            models.Index(fields=['expiry_date']),
            models.Index(fields=['price_per_unit']),
            models.Index(fields=['rating']),          # for sorting by rating
        ]

    def save(self, *args, **kwargs):
        """Auto-calculate expiry_date and generate SKU when needed."""
        if self.harvest_date and self.shelf_life_days and not self.expiry_date:
            self.expiry_date = self.harvest_date + timedelta(days=self.shelf_life_days)
        super().save(*args, **kwargs)

        if not self.sku and self.category_id:
            self.sku = f"{self.category.code}-{self.id:06d}"
            super().save(update_fields=['sku'])

    def __str__(self):
        title = self.name
        if self.variety:
            title = f"{self.name} ({self.variety})"
        return f"{title} - {self.farmer.user.phone} @ {self.price_per_unit}/{self.unit}"