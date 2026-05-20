# backend/django_admin/apps/payments/models/abstract_payment.py
from django.db import models
from shared.db_models.base import BaseModel

class AbstractPayment(BaseModel):
    """
    Abstract base for future payment methods (card, bank transfer, etc.).
    Not used in MVP – all payments go through paybill app.
    """
    PAYMENT_STATUS = [
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
        ('refunded', 'Refunded'),
    ]
    order = models.ForeignKey('orders.Order', on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='pending')
    gateway_reference = models.CharField(max_length=100, blank=True)

    class Meta:
        abstract = True