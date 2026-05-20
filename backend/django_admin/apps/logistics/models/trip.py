# django_admin/apps/logistics/models/trip.py
# backend/django_admin/apps/logistics/models/trip.py
from django.db import models
from shared.db_models.base import BaseModel
from apps.orders.models import Order
from apps.users.models import TransportProviderProfile

class Trip(BaseModel):
    """Tracks a delivery from farm to buyer, assigned to one provider."""
    TRIP_STATUS = [
        ('assigned', 'Assigned'),
        ('picked_up', 'Picked Up from Farm'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
        ('disputed', 'Disputed'),
    ]

    order = models.OneToOneField(Order, on_delete=models.CASCADE, related_name='trip')
    provider = models.ForeignKey(TransportProviderProfile, on_delete=models.SET_NULL, null=True, related_name='trips')
    status = models.CharField(max_length=20, choices=TRIP_STATUS, default='assigned')

    # Location tracking
    pickup_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    pickup_lng = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    delivery_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    delivery_lng = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    # Photos
    pickup_photo = models.ImageField(upload_to='trips/pickup/', blank=True, null=True)
    delivery_photo = models.ImageField(upload_to='trips/delivery/', blank=True, null=True)

    # Timestamps
    picked_up_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)

    # OTP (generated per delivery)
    otp_code = models.CharField(max_length=6, blank=True)
    otp_expires_at = models.DateTimeField(null=True, blank=True)
    otp_attempts = models.PositiveSmallIntegerField(default=0)

    class Meta:
        db_table = 'trips'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', 'provider']),
            models.Index(fields=['order']),
        ]

    def __str__(self):
        return f"Trip {self.id} - Order {self.order.id} - {self.status}"