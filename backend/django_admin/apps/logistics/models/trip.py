# backend/django_admin/apps/logistics/models/trip.py
from django.db import models
from shared.db_models.base import BaseModel

class Trip(BaseModel):
    """Tracks a delivery from farm to buyer, assigned to one provider."""
    
    # ── Status choices (with offered/accepted for marketplace flow) ──
    TRIP_STATUS = [
        ('offered', 'Offered to Provider Pool'),
        ('accepted', 'Accepted by Provider'),
        ('picked_up', 'Picked Up from Farm'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
        ('disputed', 'Disputed'),
    ]

    order = models.OneToOneField('orders.Order', on_delete=models.CASCADE, related_name='trip')
    provider = models.ForeignKey('users.TransportProviderProfile', on_delete=models.SET_NULL, null=True, related_name='trips')
    status = models.CharField(max_length=20, choices=TRIP_STATUS, default='offered')

    # ── Tracking fields ──
    pickup_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    pickup_lng = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    delivery_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    delivery_lng = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    # ── Photos ──
    pickup_photo = models.ImageField(upload_to='trips/pickup/', blank=True, null=True)
    delivery_photo = models.ImageField(upload_to='trips/delivery/', blank=True, null=True)

    # ── Timestamps ──
    accepted_at = models.DateTimeField(null=True, blank=True)
    arrived_at_farm = models.DateTimeField(null=True, blank=True, help_text="When provider arrived at pickup")
    picked_up_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)

    # ── Address & distance ──
    pickup_address = models.CharField(max_length=200, blank=True, help_text="Pickup address string for display")
    distance_km = models.DecimalField(max_digits=6, decimal_places=2, default=0, help_text="Pickup → delivery distance in km")
    eta_minutes = models.PositiveIntegerField(default=0, help_text="Estimated minutes to delivery (updated in real-time)")

    # ── Fee tracking ──
    agreed_fee = models.DecimalField(
        max_digits=10, decimal_places=2, default=0,
        help_text="Total delivery fee (before commission) agreed at assignment"
    )
    waiting_surcharge = models.DecimalField(
        max_digits=10, decimal_places=2, default=0,
        help_text="Additional waiting time charge (added after pickup)"
    )

    # ── OTP ──
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