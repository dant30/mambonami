# backend/django_admin/apps/orders/models/order.py
# backend/django_admin/apps/orders/models/order.py
from django.db import models
from django.utils import timezone
from shared.db_models.base import BaseModel
from django.conf import settings

class Order(BaseModel):
    """Main order – groups multiple farmer‑specific sub‑orders."""
    STATUS_CHOICES = [
        ('cart', 'Cart'),
        ('placed', 'Placed (pending payment)'),
        ('paid_escrow', 'Paid (Escrow held)'),
        ('transport_assigned', 'Transport Assigned'),
        ('picked_up', 'Picked Up'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
        ('disputed', 'Disputed'),
    ]
    buyer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name='orders',
        limit_choices_to={'role__in': ['buyer', 'retailer']}
    )
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    delivery_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    platform_commission = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='cart')
    account_number = models.CharField(max_length=50, unique=True, blank=True, db_index=True)
    delivery_address = models.TextField()
    scheduled_date = models.DateField()
    scheduled_time_window = models.CharField(max_length=50, help_text="e.g., 10:00-12:00")
    # Transport provider (assigned after all farmers ready)
    assigned_provider = models.ForeignKey(
        'users.TransportProviderProfile',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='assigned_orders'
    )
    # Payment tracking
    paybill_transaction_code = models.CharField(max_length=50, blank=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'orders'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', 'created_at']),
            models.Index(fields=['buyer', 'status']),
            models.Index(fields=['account_number']),
        ]

    def __str__(self):
        return f"Order {self.id} – {self.buyer.phone} – {self.status}"

    def mark_paid(self, transaction_code):
        """Transition to paid escrow."""
        self.status = 'paid_escrow'
        self.paybill_transaction_code = transaction_code
        self.paid_at = timezone.now()
        self.save(update_fields=['status', 'paybill_transaction_code', 'paid_at'])

    def is_fully_confirmed(self):
        """All sub‑orders are confirmed by farmers."""
        return all(sub.status == 'confirmed' for sub in self.sub_orders.all())

    def are_all_farmers_ready(self):
        """All farmers marked ready for pickup."""
        return all(sub.status == 'ready' for sub in self.sub_orders.all())