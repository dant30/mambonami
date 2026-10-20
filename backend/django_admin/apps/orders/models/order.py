# backend/django_admin/apps/orders/models/order.py
from django.db import models
from django.utils import timezone
from shared.db_models.base import BaseModel
from django.conf import settings

class Order(BaseModel):
    """Main order – groups multiple farmer‑specific sub‑orders."""
    FULFILLMENT_CHOICES = [
        ('delivery', 'Delivery'),
        ('self_pickup', 'Self Pickup'),
    ]
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
    fulfillment_type = models.CharField(
        max_length=20,
        choices=FULFILLMENT_CHOICES,
        default='delivery',
    )
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    delivery_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    platform_commission = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='cart')
    account_number = models.CharField(max_length=50, unique=True, blank=True, db_index=True)
    delivery_address = models.TextField(blank=True)
    delivery_street = models.CharField(max_length=200, blank=True, help_text="Street address or delivery line")
    delivery_city = models.CharField(max_length=100, blank=True, help_text="City or town for delivery")
    delivery_postal_code = models.CharField(max_length=20, blank=True, help_text="Postal code or ZIP")
    delivery_landmark = models.CharField(max_length=200, blank=True, help_text="Optional delivery landmark")
    delivery_lat = models.DecimalField(
        max_digits=9, decimal_places=6,
        null=True,
        blank=True,
        help_text="Latitude of delivery destination"
    )
    delivery_lng = models.DecimalField(
        max_digits=9, decimal_places=6,
        null=True,
        blank=True,
        help_text="Longitude of delivery destination"
    )
    total_weight_kg = models.DecimalField(
        max_digits=10, decimal_places=2, default=0,
        help_text="Sum of product weights in kg"
    )
    scheduled_date = models.DateField()
    scheduled_time_window = models.CharField(max_length=50, help_text="e.g., 10:00-12:00")
    assigned_provider = models.ForeignKey(
        'users.TransportProviderProfile',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='assigned_orders'
    )
    paybill_transaction_code = models.CharField(max_length=50, blank=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)

    # NEW FIELDS
    promo_code = models.CharField(max_length=30, blank=True)
    discount_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)

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

    def save(self, *args, **kwargs):
        if not self.delivery_address and (self.delivery_street or self.delivery_city or self.delivery_postal_code or self.delivery_landmark):
            address_parts = [part for part in [self.delivery_street, self.delivery_city, self.delivery_postal_code, self.delivery_landmark] if part]
            self.delivery_address = ', '.join(address_parts)
        super().save(*args, **kwargs)

    def mark_paid(self, transaction_code):
        self.status = 'paid_escrow'
        self.paybill_transaction_code = transaction_code
        self.paid_at = timezone.now()
        self.save(update_fields=['status', 'paybill_transaction_code', 'paid_at'])

    def is_fully_confirmed(self):
        sub_orders = self.sub_orders.all()
        return sub_orders.exists() and not sub_orders.exclude(status='confirmed').exists()

    def are_all_farmers_ready(self):
        sub_orders = self.sub_orders.all()
        return sub_orders.exists() and not sub_orders.exclude(status='ready').exists()