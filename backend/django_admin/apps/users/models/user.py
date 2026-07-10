# backend/django_admin/apps/users/models/user.py
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator
from django.db import models
from shared.db_models.base import BaseModel
from core.validators import normalize_phone_number, validate_gps_coordinates, validate_phone_number


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
    national_id = models.CharField(
        max_length=30,
        blank=True,
        null=True,
        unique=True,
        help_text='National identification number for KYC and verification',
    )
    national_id_verified = models.BooleanField(
        default=False,
        help_text='Has the user national ID been verified by admin?',
    )

    # ─── NEW FIELDS ──────────────────────────────────────────────
    avatar = models.ImageField(upload_to='avatars/users/', blank=True, null=True)
    middle_name = models.CharField(max_length=150, blank=True, null=True, help_text='Second given name (middle name)')
    national_id = models.CharField(
        max_length=20,
        unique=True,
        blank=True,
        null=True,
        help_text='National ID number (optional at registration)',
    )
    is_id_verified = models.BooleanField(default=False, help_text='Admin-verified national ID')
    is_email_verified = models.BooleanField(default=False, help_text='Email confirmed via OTP/link')

    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'

    def save(self, *args, **kwargs):
        if self.phone:
            try:
                self.phone = normalize_phone_number(self.phone)
            except Exception:
                pass
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.phone} ({self.role})"

    # ─── PROPERTIES ──────────────────────────────────────────────

    @property
    def full_name(self) -> str:
        """Full name: first_name + middle_name + last_name (excluding blanks)."""
        parts = [self.first_name.strip() if self.first_name else '']
        if self.middle_name:
            parts.append(self.middle_name.strip())
        if self.last_name:
            parts.append(self.last_name.strip())
        return ' '.join(p for p in parts if p)

    @property
    def display_name(self) -> str:
        """Public‑facing name: full_name if available, else username or phone."""
        full = self.full_name
        if full:
            return full
        return self.username or self.phone


class FarmerProfile(BaseModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='farmer_profile')
    farm_gps = models.CharField(
        max_length=50,
        blank=True,
        validators=[validate_gps_coordinates],
        help_text='GPS coordinates in format lat,lng',
    )
    cooperative = models.CharField(
        max_length=100,
        blank=True,
        help_text='Cooperative or group affiliation for the farmer',
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

    # ─── NEW FIELDS ──────────────────────────────────────────────
    rating = models.FloatField(default=5.0, help_text="Average buyer rating 1-5")
    total_orders = models.PositiveIntegerField(default=0)
    avatar = models.ImageField(upload_to='avatars/farmers/', blank=True, null=True)

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
    bank_account = models.CharField(
        max_length=50,
        blank=True,
        help_text='Bank account number for transport provider payouts',
    )
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

    # ─── NEW FIELD ──────────────────────────────────────────────
    avatar = models.ImageField(upload_to='avatars/transport/', blank=True, null=True)

    class Meta:
        db_table = 'transport_provider_profiles'
        verbose_name = 'Transport Provider Profile'
        verbose_name_plural = 'Transport Provider Profiles'

    def __str__(self):
        return f"Provider: {self.user.phone} ({self.vehicle_type or 'unassigned'})"


class BuyerProfile(BaseModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='buyer_profile')
    delivery_address = models.TextField(blank=True, help_text='Default delivery address for the buyer')
    delivery_instructions = models.TextField(blank=True, help_text='Preferred delivery instructions')
    bank_account = models.CharField(max_length=50, blank=True, help_text='Bank account for buyer refunds')

    class Meta:
        db_table = 'buyer_profiles'
        verbose_name = 'Buyer Profile'
        verbose_name_plural = 'Buyer Profiles'

    def __str__(self):
        return f"Buyer: {self.user.phone}"


class RetailerProfile(BaseModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='retailer_profile')
    business_name = models.CharField(max_length=150, blank=True, help_text='Retailer business name')
    owner_full_name = models.CharField(max_length=150, blank=True, help_text='Retailer owner name')
    business_phone = models.CharField(
        max_length=15,
        blank=True,
        validators=[validate_phone_number],
        help_text='Retailer contact phone number',
    )
    business_email = models.EmailField(blank=True, help_text='Retailer business email address')
    business_address = models.TextField(blank=True, help_text='Retailer business address')
    business_type = models.CharField(max_length=100, blank=True, help_text='Category of retailer business')
    kra_pin = models.CharField(max_length=20, blank=True, help_text='KRA PIN for business registration')
    bank_account = models.CharField(max_length=50, blank=True, help_text='Retailer bank account for payouts')

    class Meta:
        db_table = 'retailer_profiles'
        verbose_name = 'Retailer Profile'
        verbose_name_plural = 'Retailer Profiles'

    def __str__(self):
        return f"Retailer: {self.business_name or self.user.phone}"