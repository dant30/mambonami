# backend/django_admin/apps/orders/models/order_item.py
# backend/django_admin/apps/orders/models/order_item.py
from django.db import models
from django.utils import timezone
from shared.db_models.base import BaseModel

class SubOrder(BaseModel):
    """
    Sub‑order for one farmer.
    Contains one or more order items (products from same farmer).
    """
    SUBORDER_STATUS = [
        ('pending', 'Pending Farmer Confirmation'),
        ('confirmed', 'Farmer Confirmed'),
        ('ready', 'Ready for Pickup'),
        ('cancelled', 'Cancelled by Farmer'),
    ]
    order = models.ForeignKey('orders.Order', on_delete=models.CASCADE, related_name='sub_orders')
    farmer = models.ForeignKey('users.FarmerProfile', on_delete=models.PROTECT, related_name='sub_orders')
    status = models.CharField(max_length=20, choices=SUBORDER_STATUS, default='pending')
    subtotal = models.DecimalField(max_digits=10, decimal_places=2)
    farmer_payout = models.DecimalField(max_digits=10, decimal_places=2, help_text="Amount payable to the farmer after platform commission")
    confirmed_at = models.DateTimeField(null=True, blank=True)
    ready_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'sub_orders'
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['order', 'farmer']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return f"SubOrder {self.id} – Order {self.order.id} – Farmer {self.farmer.user.phone}"

    def confirm(self):
        """Farmer accepts order."""
        self.status = 'confirmed'
        self.confirmed_at = timezone.now()
        self.save(update_fields=['status', 'confirmed_at'])

    def mark_ready(self):
        """Farmer marks ready for pickup."""
        if self.status == 'confirmed':
            self.status = 'ready'
            self.ready_at = timezone.now()
            self.save(update_fields=['status', 'ready_at'])

class OrderItem(BaseModel):
    """Individual product line item within a sub‑order."""
    sub_order = models.ForeignKey(SubOrder, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey('products.Product', on_delete=models.PROTECT)
    quantity = models.DecimalField(max_digits=12, decimal_places=2)
    unit_price = models.DecimalField(max_digits=10, decimal_places=2)
    total_price = models.DecimalField(max_digits=12, decimal_places=2)

    class Meta:
        db_table = 'order_items'

    def __str__(self):
        return f"{self.quantity}x {self.product.name}"