from decimal import Decimal
from django.db import models


class PromoCode(models.Model):
    DISCOUNT_FIXED = 'fixed'
    DISCOUNT_PERCENT = 'percent'
    DISCOUNT_TYPES = [
        (DISCOUNT_FIXED, 'Fixed amount'),
        (DISCOUNT_PERCENT, 'Percentage'),
    ]

    code = models.CharField(max_length=64, unique=True)
    description = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    valid_from = models.DateTimeField(null=True, blank=True)
    valid_until = models.DateTimeField(null=True, blank=True)
    discount_type = models.CharField(max_length=10, choices=DISCOUNT_TYPES, default=DISCOUNT_FIXED)
    discount_value = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0.00'))
    max_discount_amount = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    times_used = models.IntegerField(default=0)
    max_uses = models.IntegerField(default=0)

    class Meta:
        app_label = 'orders'
        db_table = 'orders_promocode'

    def __str__(self):
        return self.code
