# backend/django_admin/apps/paybill/models/mpesa_callback.py
from django.db import models
from shared.db_models.base import BaseModel


class MpesaCallback(BaseModel):
    """
    Idempotency table for M-Pesa IPN callbacks.
    Primary key is the TransactionCode from Safaricom.
    """
    # Remove inherited auto PK, uuid, and timestamps from BaseModel when this model
    # uses a domain-specific primary key and custom processing timestamp.
    id = None
    uuid = None
    created_at = None
    updated_at = None

    transaction_code = models.CharField(
        max_length=50,
        primary_key=True,
        help_text="Unique transaction code from Safaricom (e.g., 'QLFJ78T9KJ')"
    )
    order_id = models.IntegerField(
        null=True, blank=True,
        help_text="Order ID (internal) that this payment corresponds to"
    )
    callback_payload = models.JSONField(
        default=dict,
        help_text="Full raw payload received from Safaricom (for debugging)"
    )
    is_processed = models.BooleanField(
        default=False,
        help_text="Whether this callback has been fully processed"
    )
    processing_attempts = models.PositiveIntegerField(
        default=0,
        help_text="Number of processing attempts (for retries)"
    )
    processed_at = models.DateTimeField(
        null=True, blank=True,
        help_text="Timestamp when processing completed"
    )

    class Meta:
        db_table = 'mpesa_callbacks'
        verbose_name = 'M-Pesa Callback'
        verbose_name_plural = 'M-Pesa Callbacks'

    def __str__(self):
        return f"{self.transaction_code} → Order {self.order_id}"