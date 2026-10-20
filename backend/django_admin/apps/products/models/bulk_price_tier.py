from decimal import Decimal

from django.core.validators import MinValueValidator
from django.db import models

from shared.db_models.base import BaseModel


class BulkPriceTier(BaseModel):
    BUYER_ROLE_CHOICES = [
        ('any', 'Any buyer'),
        ('buyer', 'Consumer'),
        ('retailer', 'Retailer'),
    ]

    product = models.ForeignKey(
        'products.Product',
        on_delete=models.CASCADE,
        related_name='bulk_price_tiers',
    )
    buyer_role = models.CharField(max_length=20, choices=BUYER_ROLE_CHOICES, default='any')
    minimum_quantity = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal('0.01'))],
    )
    unit_price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(Decimal('0.01'))],
    )
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'bulk_price_tiers'
        ordering = ['product', 'buyer_role', '-minimum_quantity']
        constraints = [
            models.UniqueConstraint(
                fields=['product', 'buyer_role', 'minimum_quantity'],
                name='unique_product_role_bulk_tier',
            ),
        ]

    def __str__(self):
        return f'{self.product.name}: {self.buyer_role} from {self.minimum_quantity} at {self.unit_price}'