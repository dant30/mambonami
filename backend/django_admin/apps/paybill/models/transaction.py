# M-Pesa transaction model
# backend/django_admin/apps/paybill/models/transaction.py
from django.db import models
from django.core.validators import MinValueValidator
from shared.db_models.base import BaseModel

class PayBillTransaction(BaseModel):
    """
    Complete log of every PayBill collection received.
    One transaction may be linked to one MpesaCallback (idempotency).
    """
    TRANSACTION_STATUS = [
        ('pending', 'Pending'),
        ('matched', 'Matched to Order'),
        ('orphaned', 'No Matching Order'),
        ('refunded', 'Refunded via B2C'),
    ]

    # Safaricom fields
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

    # Platform fields
    status = models.CharField(
        max_length=20,
        choices=TRANSACTION_STATUS,
        default='pending',
        db_index=True
    )
    matched_order_id = models.IntegerField(
        null=True, blank=True,
        help_text="Order ID if this payment was matched to an order"
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
        ]
        # Constraints removed for compatibility with target Django runtime.

    def __str__(self):
        return f"{self.transaction_code} | {self.amount} KES | {self.status}"