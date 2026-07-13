# backend/django_admin/apps/paybill/models/settlement.py
from django.db import models
from shared.db_models.base import BaseModel


class PayBillSettlement(BaseModel):
    """
    Records each daily settlement from Safaricom to the business bank account.
    """
    settlement_date = models.DateField(unique=True, db_index=True)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    reference = models.CharField(max_length=50, blank=True)
    status = models.CharField(
        max_length=20,
        choices=[('pending', 'Pending'), ('settled', 'Settled'), ('failed', 'Failed')],
        default='pending'
    )
    bank_account = models.CharField(max_length=50, blank=True, help_text="Destination bank account")
    initiated_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'paybill_settlements'
        ordering = ['-settlement_date']

    def __str__(self):
        return f"Settlement {self.settlement_date} - {self.amount} KES"