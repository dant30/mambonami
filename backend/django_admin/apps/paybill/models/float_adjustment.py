# backend/django_admin/apps/paybill/models/float_adjustment.py
from django.db import models
from django.core.validators import MinValueValidator
from django.conf import settings
from shared.db_models.base import BaseModel


class FloatAdjustment(BaseModel):
    """
    Logs every manual or automated adjustment to the PayBill float.
    Used for auditing when reserves are topped up or withdrawn.
    """
    ADJUSTMENT_TYPE = [
        ('topup', 'Manual Top‑Up'),
        ('withdrawal', 'Manual Withdrawal'),
        ('reserve_floor', 'Reserve Floor Adjustment'),
        ('settlement', 'Safaricom Settlement'),
        ('b2c', 'B2C Payout'),
        ('reconciliation', 'Reconciliation Correction'),
    ]
    SOURCE_CHOICES = [
        ('manual', 'Manual Entry'),
        ('system', 'System Job'),
        ('b2c', 'B2C Transaction'),
        ('settlement', 'Safaricom Settlement'),
        ('scheduler', 'Scheduled Task'),
        ('reconciliation', 'Reconciliation Run'),
    ]

    adjustment_type = models.CharField(max_length=20, choices=ADJUSTMENT_TYPE)
    amount = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0.01)])
    running_balance = models.DecimalField(max_digits=12, decimal_places=2, help_text="Float balance after adjustment")
    reason = models.TextField()
    initiated_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        help_text="User who initiated the adjustment (null = system)"
    )
    source = models.CharField(
        max_length=30,
        choices=SOURCE_CHOICES,
        default='manual',
        help_text="Where this adjustment originated"
    )
    reference_transaction = models.CharField(
        max_length=50,
        blank=True,
        help_text="M-Pesa transaction code if this adjustment came from a B2C or manual send"
    )

    class Meta:
        db_table = 'float_adjustments'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.adjustment_type} | {self.amount} KES | Balance: {self.running_balance}"