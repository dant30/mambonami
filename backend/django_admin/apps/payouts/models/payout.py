# backend/django_admin/apps/payouts/models/payout.py
from django.db import models
from django.core.validators import MinValueValidator
from shared.db_models.base import BaseModel
from django.conf import settings

class Payout(BaseModel):
    """Records a single B2C payout to a farmer, transport provider, or buyer refund."""
    RECIPIENT_TYPE = [
        ('farmer', 'Farmer'),
        ('transport_provider', 'Transport Provider'),
        ('buyer_refund', 'Buyer Refund'),
    ]
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
        ('retry', 'Retry Scheduled'),
    ]

    order = models.ForeignKey('orders.Order', on_delete=models.CASCADE, related_name='payouts')
    recipient_type = models.CharField(max_length=20, choices=RECIPIENT_TYPE)
    recipient_user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='payouts')
    amount = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0.01)])
    b2c_transaction_id = models.CharField(max_length=50, blank=True, help_text="Safaricom B2C transaction ID")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', db_index=True)
    error_message = models.TextField(blank=True)
    retry_count = models.PositiveSmallIntegerField(default=0)
    paid_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'payouts'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', 'retry_count']),
            models.Index(fields=['order', 'recipient_type']),
        ]

    def __str__(self):
        return f"Payout {self.id} - {self.recipient_type} - {self.amount} KES - {self.status}"