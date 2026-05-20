# MpesaCallback model for idempotency
# backend/django_admin/apps/paybill/models/mpesa_callback.py
from django.db import models

class MpesaCallback(models.Model):
    """
    Idempotency table for M-Pesa IPN callbacks.
    Primary key is the TransactionCode from Safaricom.
    """
    transaction_code = models.CharField(
        max_length=50,
        primary_key=True,
        help_text="Unique transaction code from Safaricom (e.g., 'QLFJ78T9KJ')"
    )
    order_id = models.IntegerField(
        null=True, blank=True,
        help_text="Order ID (internal) that this payment corresponds to"
    )
    processed_at = models.DateTimeField(
        auto_now_add=True,
        help_text="Timestamp when this callback was first processed"
    )
    callback_payload = models.JSONField(
        default=dict,
        help_text="Full raw payload received from Safaricom (for debugging)"
    )

    class Meta:
        db_table = 'mpesa_callbacks'
        verbose_name = 'M-Pesa Callback'
        verbose_name_plural = 'M-Pesa Callbacks'

    def __str__(self):
        return f"{self.transaction_code} → Order {self.order_id}"