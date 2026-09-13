# backend/django_admin/apps/logistics/models/trip.py
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models
from django.contrib.auth.hashers import make_password, check_password
from django.utils import timezone
from shared.db_models.base import BaseModel
from apps.users.models import User


class TripStatus(models.TextChoices):
    CREATED = "created", "Created"
    OFFERED = "offered", "Offered"
    ACCEPTED = "accepted", "Accepted"
    EN_ROUTE_PICKUP = "en_route_pickup", "Driving to Farm"
    ARRIVED_PICKUP = "arrived_pickup", "Arrived at Farm"
    PICKED_UP = "picked_up", "Picked Up"
    EN_ROUTE_DELIVERY = "en_route_delivery", "Driving to Buyer"
    ARRIVED_DELIVERY = "arrived_delivery", "Arrived at Buyer"
    OTP_PENDING = "otp_pending", "Waiting OTP"
    DELIVERED = "delivered", "Delivered"
    CANCELLED = "cancelled", "Cancelled"
    FAILED = "failed", "Delivery Failed"
    DISPUTED = "disputed", "Disputed"


class Trip(BaseModel):
    """Tracks a delivery from farm to buyer, assigned to one provider."""
    
    order = models.OneToOneField('orders.Order', on_delete=models.CASCADE, related_name='trip')
    provider = models.ForeignKey('users.TransportProviderProfile', on_delete=models.SET_NULL, null=True, related_name='trips')
    status = models.CharField(max_length=20, choices=TripStatus.choices, default=TripStatus.CREATED)

    # ── Vehicle snapshot (historical data) ──
    vehicle_type = models.CharField(max_length=20, blank=True)
    vehicle_plate = models.CharField(max_length=20, blank=True)
    vehicle_make = models.CharField(max_length=50, blank=True)
    vehicle_model = models.CharField(max_length=50, blank=True)

    # ── Current live location ──
    current_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    current_lng = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    # ── Pickup / delivery coordinates ──
    pickup_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    pickup_lng = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    delivery_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    delivery_lng = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    # ── Addresses ──
    pickup_address = models.CharField(max_length=200, blank=True)
    delivery_address = models.CharField(max_length=200, blank=True)

    # ── Route & distance ──
    straight_line_km = models.DecimalField(max_digits=6, decimal_places=2, default=0, help_text="Haversine distance")
    road_km = models.DecimalField(max_digits=6, decimal_places=2, default=0, help_text="Actual road distance (Google/OSRM)")
    eta_minutes = models.PositiveIntegerField(default=0)

    # ── Fee breakdown ──
    base_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    distance_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    weight_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    waiting_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    surge_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    commission = models.DecimalField(max_digits=10, decimal_places=2, default=0, help_text="Platform commission")
    provider_payout = models.DecimalField(max_digits=10, decimal_places=2, default=0, help_text="Amount paid to provider")
    platform_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0, help_text="Platform revenue")
    buyer_total = models.DecimalField(max_digits=10, decimal_places=2, default=0, help_text="Total charged to buyer")
    
    # ── Legacy (kept for backward compatibility) ──
    agreed_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    waiting_surcharge = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    # ── OTP (hashed) ──
    otp_hash = models.CharField(max_length=128, blank=True, help_text="Hashed OTP code")
    otp_expires_at = models.DateTimeField(null=True, blank=True)
    otp_attempts = models.PositiveSmallIntegerField(default=0)

    # ── Timestamps ──
    created_at_trip = models.DateTimeField(default=timezone.now, editable=False)
    offered_at = models.DateTimeField(null=True, blank=True)
    accepted_at = models.DateTimeField(null=True, blank=True)
    started_navigation_pickup = models.DateTimeField(null=True, blank=True)
    arrived_pickup_at = models.DateTimeField(null=True, blank=True)
    picked_up_at = models.DateTimeField(null=True, blank=True)
    left_pickup_at = models.DateTimeField(null=True, blank=True)
    started_navigation_delivery = models.DateTimeField(null=True, blank=True)
    arrived_delivery_at = models.DateTimeField(null=True, blank=True)
    otp_verified_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    cancelled_at = models.DateTimeField(null=True, blank=True)
    failed_at = models.DateTimeField(null=True, blank=True)

    # ── Audit / metadata ──
    assigned_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_trips')
    accepted_device = models.CharField(max_length=200, blank=True)
    completed_device = models.CharField(max_length=200, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)

    # ── Cancellation / failure ──
    cancel_reason = models.TextField(blank=True)
    cancelled_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='cancelled_trips')
    failure_reason = models.TextField(blank=True)

    # ── Delivery notes ──
    delivery_notes = models.TextField(blank=True)
    buyer_signature = models.ImageField(upload_to='signatures/', blank=True, null=True)

    # ── Ratings ──
    buyer_rating = models.PositiveSmallIntegerField(null=True, blank=True, validators=[MinValueValidator(1), MaxValueValidator(5)])
    provider_rating = models.PositiveSmallIntegerField(null=True, blank=True, validators=[MinValueValidator(1), MaxValueValidator(5)])

    # ── Photos ──
    # (moved to TripMedia model below)

    class Meta:
        db_table = 'trips'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', 'provider']),
            models.Index(fields=['order']),
            models.Index(fields=['provider', 'status']),
            models.Index(fields=['created_at']),
            models.Index(fields=['current_lat', 'current_lng']),
        ]

    def __str__(self):
        return f"Trip {self.id} - Order {self.order.id} - {self.status}"

    # ── OTP methods ──
    def set_otp(self, raw_otp: str):
        self.otp_hash = make_password(raw_otp)
        self.otp_attempts = 0

    def verify_otp(self, raw_otp: str) -> bool:
        return check_password(raw_otp, self.otp_hash)

    # ── Snapshot provider vehicle at assignment ──
    def snapshot_vehicle(self):
        if self.provider:
            self.vehicle_type = self.provider.vehicle_type
            self.vehicle_plate = self.provider.license_plate
            # Add vehicle make/model fields to TransportProviderProfile if needed


class TripProviderDecline(BaseModel):
    """Records a provider declining an offered trip without hiding it from others."""

    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='provider_declines')
    provider = models.ForeignKey('users.TransportProviderProfile', on_delete=models.CASCADE, related_name='trip_declines')
    reason = models.TextField(blank=True)

    class Meta:
        db_table = 'trip_provider_declines'
        constraints = [
            models.UniqueConstraint(fields=['trip', 'provider'], name='unique_trip_provider_decline'),
        ]


class TripStatusHistory(BaseModel):
    """
    Immutable log of every status change for a trip.
    Used for audit trail and timeline display.
    """
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='status_history')
    status = models.CharField(max_length=20, choices=TripStatus.choices)
    changed_at = models.DateTimeField(auto_now_add=True)
    
    # ── Location snapshots ──
    location_lat = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    location_lng = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    
    # ── Device telemetry ──
    battery_level = models.PositiveSmallIntegerField(null=True, blank=True)
    speed_kmh = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    
    # ── Who triggered this status change ──
    actor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='status_changes')
    source = models.CharField(max_length=20, choices=[
        ('system', 'System'),
        ('provider', 'Provider'),
        ('buyer', 'Buyer'),
        ('admin', 'Admin'),
    ], default='system')
    
    # ── Additional context ──
    note = models.TextField(blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.CharField(max_length=255, blank=True)

    class Meta:
        db_table = 'trip_status_history'
        ordering = ['changed_at']
        indexes = [
            models.Index(fields=['trip', 'changed_at']),
            models.Index(fields=['actor']),
        ]

    def __str__(self):
        return f"{self.trip.id} → {self.status} at {self.changed_at}"


class TripLocationPing(BaseModel):
    """
    Continuous GPS tracking during a delivery.
    Uploaded every 30-60 seconds from provider app.
    """
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='location_pings')
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    
    # ── Telemetry ──
    heading = models.PositiveSmallIntegerField(null=True, blank=True, help_text="Direction in degrees 0-359")
    speed_kmh = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    accuracy_m = models.PositiveSmallIntegerField(null=True, blank=True, help_text="GPS accuracy in meters")
    altitude_m = models.PositiveIntegerField(null=True, blank=True)
    battery_level = models.PositiveSmallIntegerField(null=True, blank=True)
    
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'trip_location_pings'
        ordering = ['timestamp']
        indexes = [
            models.Index(fields=['trip', 'timestamp']),
            models.Index(fields=['latitude', 'longitude']),
        ]

    def __str__(self):
        return f"{self.trip.id} - {self.latitude},{self.longitude} at {self.timestamp}"


class TripMedia(BaseModel):
    """
    Photos/media uploaded during a trip (pickup, delivery, evidence).
    """
    MEDIA_TYPES = [
        ('pickup', 'Pickup Photo'),
        ('delivery', 'Delivery Photo'),
        ('evidence_buyer', 'Buyer Evidence'),
        ('evidence_provider', 'Provider Evidence'),
        ('signature', 'Buyer Signature'),
        ('other', 'Other'),
    ]
    
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='media')
    media_type = models.CharField(max_length=20, choices=MEDIA_TYPES)
    image = models.ImageField(upload_to='trips/media/')
    uploaded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='trip_media')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    # ── Location where photo was taken ──
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    
    # ── Metadata ──
    caption = models.CharField(max_length=255, blank=True)
    is_verified = models.BooleanField(default=False, help_text="Admin verified")

    class Meta:
        db_table = 'trip_media'
        ordering = ['uploaded_at']

    def __str__(self):
        return f"{self.trip.id} - {self.media_type} at {self.uploaded_at}"