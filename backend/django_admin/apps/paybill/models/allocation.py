# backend/django_admin/apps/paybill/models/allocation.py
from django.db import models
from shared.db_models.base import BaseModel


class PaymentAllocation(BaseModel):
    """
    Allocates a PayBillTransaction to one or more specific orders,
    delivery fees, or wallet top-ups.
    """
    transaction = models.ForeignKey(
        'PayBillTransaction',
        on_delete=models.CASCADE,
        related_name='allocations'
    )
    order = models.ForeignKey(
        'orders.Order',
        on_delete=models.CASCADE,
        related_name='payment_allocations',
        null=True,
        blank=True
    )
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    allocation_type = models.CharField(
        max_length=20,
        choices=[
            ('order', 'Order Payment'),
            ('delivery', 'Delivery Fee'),
            ('wallet', 'Wallet Top-up'),
            ('refund', 'Refund'),
        ],
        default='order'
    )

    class Meta:
        db_table = 'payment_allocations'

    def __str__(self):
        return f"{self.transaction.transaction_code} → {self.allocation_type} {self.order_id}"