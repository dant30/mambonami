# backend/django_admin/apps/paybill/models/float_adjustment.py
from django.db import models
from django.core.validators import MinValueValidator
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
    ]

    adjustment_type = models.CharField(max_length=20, choices=ADJUSTMENT_TYPE)
    amount = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0.01)])
    running_balance = models.DecimalField(max_digits=12, decimal_places=2, help_text="Float balance after adjustment")
    reason = models.TextField()
    initiated_by = models.CharField(max_length=100, help_text="Admin username or system")
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