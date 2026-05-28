# backend/django_admin/apps/users/models/user.py
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator
from django.db import models
from shared.db_models.base import BaseModel
from core.validators import validate_gps_coordinates, validate_phone_number


class User(AbstractUser):   # no BaseModel
    ROLE_CHOICES = [
        ('farmer', 'Farmer'),
        ('buyer', 'Buyer'),
        ('retailer', 'Retailer'),
        ('transport_provider', 'Transport Provider'),
    ]

    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='buyer')
    phone = models.CharField(
        max_length=15,
        unique=True,
        validators=[validate_phone_number],
        help_text='Primary login phone number',
    )
    is_phone_verified = models.BooleanField(default=False)
    email = models.EmailField(blank=True, null=True)

    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'

    def __str__(self):
        return f"{self.phone} ({self.role})"


class FarmerProfile(BaseModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='farmer_profile')
    farm_gps = models.CharField(
        max_length=50,
        blank=True,
        validators=[validate_gps_coordinates],
        help_text='GPS coordinates in format lat,lng',
    )
    coop_verified = models.BooleanField(
        default=False,
        help_text='Admin-verified cooperative endorsement',
    )
    bank_account = models.CharField(max_length=50, blank=True, help_text='Bank account number')
    mpesa_number = models.CharField(
        max_length=15,
        blank=True,
        validators=[validate_phone_number],
        help_text='M-Pesa number for the farmer',
    )
    total_sales = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    class Meta:
        db_table = 'farmer_profiles'
        verbose_name = 'Farmer Profile'
        verbose_name_plural = 'Farmer Profiles'

    def __str__(self):
        return f"Farmer: {self.user.phone}"


class TransportProviderProfile(BaseModel):
    VEHICLE_TYPES = [
        ('motorcycle', 'Motorcycle'),
        ('pickup', 'Pickup Truck'),
        ('lorry', 'Lorry'),
        ('van', 'Van'),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='transport_profile')
    vehicle_type = models.CharField(max_length=20, choices=VEHICLE_TYPES, blank=True)
    capacity_kg = models.PositiveIntegerField(
        default=100,
        validators=[MinValueValidator(1)],
        help_text='Vehicle capacity in kilograms',
    )
    license_plate = models.CharField(max_length=20, blank=True)
    driver_license = models.CharField(max_length=50, blank=True)
    deposit_paid = models.BooleanField(default=False)
    deposit_transaction_id = models.CharField(max_length=50, blank=True)
    is_approved = models.BooleanField(
        default=False,
        help_text='Admin approval after deposit verification',
    )
    rating = models.FloatField(default=5.0)
    total_deliveries = models.PositiveIntegerField(default=0)
    
    # Dynamic pricing parameters (provider-specific)
    base_rate_per_km = models.DecimalField(
        max_digits=5, decimal_places=2, default=25.00,
        help_text="Provider's base rate in KES per km"
    )
    waiting_grace_minutes = models.PositiveIntegerField(
        default=15,
        help_text="Minutes allowed before waiting surcharge starts"
    )
    waiting_rate_per_min = models.DecimalField(
        max_digits=5, decimal_places=2, default=2.00,
        help_text="Extra KES per minute after grace period"
    )

    class Meta:
        db_table = 'transport_provider_profiles'
        verbose_name = 'Transport Provider Profile'
        verbose_name_plural = 'Transport Provider Profiles'

    def __str__(self):
        return f"Provider: {self.user.phone} ({self.vehicle_type or 'unassigned'})"
