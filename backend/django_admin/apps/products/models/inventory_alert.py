from django.db import models
from django.conf import settings
from shared.db_models.base import BaseModel
from .product import Product


class InventoryAlertRule(BaseModel):
    ALERT_TYPES = [
        ('stock_low', 'Low stock'),
        ('shelf_life', 'Shelf-life alert'),
        ('out_of_stock', 'Out of stock'),
    ]

    farmer = models.ForeignKey('users.FarmerProfile', on_delete=models.CASCADE, related_name='inventory_alert_rules')
    alert_type = models.CharField(max_length=20, choices=ALERT_TYPES)
    threshold_quantity = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    threshold_days = models.PositiveIntegerField(default=0)
    enabled = models.BooleanField(default=True)

    class Meta:
        db_table = 'inventory_alert_rules'

    def __str__(self):
        return f"{self.farmer.user.phone} - {self.alert_type}"


class InventoryAlert(BaseModel):
    ALERT_TYPES = InventoryAlertRule.ALERT_TYPES
    SEVERITY_CHOICES = [
        ('info', 'Info'),
        ('warning', 'Warning'),
        ('critical', 'Critical'),
    ]

    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='inventory_alerts')
    alert_type = models.CharField(max_length=20, choices=ALERT_TYPES)
    severity = models.CharField(max_length=20, choices=SEVERITY_CHOICES, default='warning')
    message = models.TextField()
    is_active = models.BooleanField(default=True)
    resolved_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'inventory_alerts'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.product.name} - {self.alert_type}"
