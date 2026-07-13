# backend/django_admin/apps/paybill/models/transaction.py
from django.db import models
from django.core.validators import MinValueValidator
from django.conf import settings
from shared.db_models.base import BaseModel
from apps.orders.models import Order


class PayBillTransaction(BaseModel):
    """
    Complete log of every PayBill collection received.
    One transaction may be linked to one MpesaCallback (idempotency).
    """
    TRANSACTION_STATUS = [
        ('received', 'Received'),
        ('validated', 'Validated'),
        ('matched', 'Matched to Order'),
        ('allocated', 'Allocated'),
        ('completed', 'Completed'),
        ('orphaned', 'No Matching Order'),
        ('refund_pending', 'Refund Pending'),
        ('refunded', 'Refunded via B2C'),
        ('failed', 'Failed'),
        ('reversed', 'Reversed'),
    ]

    # ── Safaricom fields ──────────────────────────────────────────────
    transaction_code = models.CharField(
        max_length=50,
        unique=True,
        db_index=True,
        help_text="M-Pesa TransactionCode (same as MpesaCallback PK)"
    )
    amount = models.DecimalField(
        max_digits=10, decimal_places=2,
        validators=[MinValueValidator(0.01)]
    )
    account_number = models.CharField(
        max_length=50,
        db_index=True,
        help_text="PayBill account number (e.g., ORD-12345, DEP-TRANSPORT-42)"
    )
    sender_phone = models.CharField(
        max_length=15,
        help_text="Buyer's M-Pesa phone number"
    )
    transaction_time = models.DateTimeField(
        help_text="Timestamp from Safaricom (original transaction time)"
    )
    # New fields from Safaricom payload
    payer_first_name = models.CharField(max_length=50, blank=True)
    payer_middle_name = models.CharField(max_length=50, blank=True)
    payer_last_name = models.CharField(max_length=50, blank=True)
    business_shortcode = models.CharField(
        max_length=10,
        blank=True,
        help_text="PayBill number used (e.g., 123456)"
    )
    transaction_type = models.CharField(
        max_length=20,
        blank=True,
        help_text="e.g., Pay Bill, Buy Goods, B2B, B2C"
    )
    currency = models.CharField(max_length=3, default='KES')

    # ── Platform fields ──────────────────────────────────────────────
    status = models.CharField(
        max_length=20,
        choices=TRANSACTION_STATUS,
        default='received',
        db_index=True
    )

    # Link to order (now a proper ForeignKey)
    matched_order = models.ForeignKey(
        Order,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='paybill_transactions',
        help_text="Order this payment is matched to"
    )

    # Link to the idempotency callback record
    callback = models.OneToOneField(
        'MpesaCallback',
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='transaction',
        help_text="The callback record that created this transaction"
    )

    running_balance = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
        help_text="Float balance after this transaction"
    )
    notes = models.TextField(blank=True)

    class Meta:
        db_table = 'paybill_transactions'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['transaction_code', 'status']),
            models.Index(fields=['account_number', 'status']),
            models.Index(fields=['matched_order']),
        ]

    def __str__(self):
        return f"{self.transaction_code} | {self.amount} KES | {self.status}"