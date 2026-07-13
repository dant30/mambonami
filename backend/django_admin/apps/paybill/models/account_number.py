# backend/django_admin/apps/paybill/models/account_number.py
from django.db import models
from django.conf import settings
from shared.db_models.base import BaseModel


class AccountNumberReservation(BaseModel):
    """
    Tracks all generated PayBill account numbers to prevent collisions
    and provide a reconciliation source.
    """
    ACCOUNT_PREFIXES = [
        ('ORD', 'Order'),
        ('DEP', 'Deposit'),
        ('REF', 'Refund'),
    ]
    account_number = models.CharField(
        max_length=50,
        unique=True,
        db_index=True,
        help_text="Full account number shown to user (e.g., ORD-12345)"
    )
    prefix = models.CharField(
        max_length=3,
        choices=ACCOUNT_PREFIXES,
        help_text="Type of account number"
    )
    related_object_id = models.IntegerField(
        help_text="ID of the related object (order_id, user_id, etc.)"
    )
    related_object_type = models.CharField(
        max_length=50,
        help_text="Model name: 'Order', 'TransportProvider', etc."
    )
    expires_at = models.DateTimeField(
        null=True, blank=True,
        help_text="If set, this account number is no longer valid after this time"
    )
    is_used = models.BooleanField(default=False)
    used_at = models.DateTimeField(
        null=True, blank=True,
        help_text="When this account number was actually used in a payment"
    )
    reserved_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True, blank=True,
        on_delete=models.SET_NULL,
        help_text="User who reserved this account number"
    )

    class Meta:
        db_table = 'account_number_reservations'
        unique_together = [('prefix', 'related_object_id', 'related_object_type')]

    def __str__(self):
        return f"{self.account_number} → {self.related_object_type} {self.related_object_id}"