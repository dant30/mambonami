# backend/django_admin/apps/users/models/user.py
import uuid

from django.contrib.auth.models import AbstractUser
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models
from shared.db_models.base import BaseModel
from core.validators import normalize_phone_number, validate_phone_number

from core.storage_backends import PrivateMediaStorage

verification_document_storage = PrivateMediaStorage()


def generate_referral_code():
    return uuid.uuid4().hex[:12].upper()


# ────────────────────────────────────────────────────────────────
# ENUMS (TextChoices)
# ────────────────────────────────────────────────────────────────

class Role(models.TextChoices):
    FARMER = "farmer", "Farmer"
    BUYER = "buyer", "Buyer"
    RETAILER = "retailer", "Retailer"
    TRANSPORT_PROVIDER = "transport_provider", "Transport Provider"


class AccountStatus(models.TextChoices):
    PENDING = "pending", "Pending Verification"
    VERIFIED = "verified", "Verified"
    SUSPENDED = "suspended", "Suspended"
    BANNED = "banned", "Banned"


class KycStatus(models.TextChoices):
    PENDING = "pending", "Pending"
    APPROVED = "approved", "Approved"
    REJECTED = "rejected", "Rejected"
    EXPIRED = "expired", "Expired"


# ────────────────────────────────────────────────────────────────
# VERIFICATION DOCUMENT
# ────────────────────────────────────────────────────────────────

class VerificationDocument(BaseModel):
    DOCUMENT_TYPES = [
        ('national_id', 'National ID'),
        ('business_license', 'Business License'),
        ('coop_certificate', 'Cooperative Certificate'),
        ('driver_license', 'Driver License'),
        ('other', 'Other'),
    ]
    STATUS_CHOICES = [
        ('submitted', 'Submitted'),
        ('reviewed', 'Reviewed'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='verification_documents')
    document_type = models.CharField(max_length=30, choices=DOCUMENT_TYPES)
    file = models.FileField(
        upload_to='verification/',
        storage=verification_document_storage,
        blank=True,
        null=True,
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='submitted', db_index=True)
    notes = models.TextField(blank=True)
    reviewed_by = models.ForeignKey('users.User', on_delete=models.SET_NULL, null=True, blank=True, related_name='reviewed_documents')
    reviewed_at = models.DateTimeField(null=True, blank=True)

    # ─── NEW FIELDS ──────────────────────────────────────────────
    expiry_date = models.DateTimeField(null=True, blank=True, help_text="Document expiration date")
    document_number = models.CharField(max_length=50, blank=True, help_text="Official document number")
    verified_by = models.ForeignKey('users.User', on_delete=models.SET_NULL, null=True, blank=True, related_name='verified_documents')
    mime_type = models.CharField(max_length=50, blank=True, help_text="File MIME type (image/png, application/pdf)")

    class Meta:
        db_table = 'verification_documents'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.phone} - {self.document_type} ({self.status})"


# ────────────────────────────────────────────────────────────────
# TRUST SCORE
# ────────────────────────────────────────────────────────────────

class TrustScore(BaseModel):
    BAND_CHOICES = [
        ('poor', 'Poor'),
        ('fair', 'Fair'),
        ('good', 'Good'),
        ('excellent', 'Excellent'),
    ]

    user = models.OneToOneField('users.User', on_delete=models.CASCADE, related_name='trust_score')
    score = models.PositiveIntegerField(default=0)
    score_band = models.CharField(max_length=20, choices=BAND_CHOICES, default='fair')
    reason = models.TextField(blank=True)
    last_updated_at = models.DateTimeField(auto_now=True)

    # ─── NEW FIELDS (explainable trust score) ──────────────────
    orders_completed = models.PositiveIntegerField(default=0)
    late_deliveries = models.PositiveIntegerField(default=0)
    disputes = models.PositiveIntegerField(default=0)
    cancelled_orders = models.PositiveIntegerField(default=0)
    verification_level = models.CharField(max_length=20, default='basic')
    payment_history = models.JSONField(default=list, blank=True, help_text="Payment history summary")
    last_calculated = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'trust_scores'

    def __str__(self):
        return f"{self.user.phone} - {self.score} ({self.score_band})"


# ────────────────────────────────────────────────────────────────
# USER (CUSTOM USER MODEL)
# ────────────────────────────────────────────────────────────────

class User(AbstractUser):
    # ─── ROLE ──────────────────────────────────────────────────
    role = models.CharField(
        max_length=30,
        choices=Role.choices,
        default=Role.BUYER,
        db_index=True,
    )

    # ─── PHONE (primary login) ────────────────────────────────
    phone = models.CharField(
        max_length=15,
        unique=True,
        db_index=True,
        validators=[validate_phone_number],
        help_text='Primary login phone number',
    )

    # ─── VERIFICATION ──────────────────────────────────────────
    is_phone_verified = models.BooleanField(default=False)
    is_email_verified = models.BooleanField(default=False)
    email = models.EmailField(blank=True, null=True, db_index=True)

    # ─── KYC ──────────────────────────────────────────────────
    kyc_status = models.CharField(
        max_length=20,
        choices=KycStatus.choices,
        default=KycStatus.PENDING,
        db_index=True,
        help_text="KYC verification status",
    )
    national_id = models.CharField(
        max_length=20,
        unique=True,
        blank=True,
        null=True,
        db_index=True,
        help_text='National ID number (optional at registration)',
    )

    # ─── ACCOUNT STATUS ────────────────────────────────────────
    account_status = models.CharField(
        max_length=20,
        choices=AccountStatus.choices,
        default=AccountStatus.PENDING,
        db_index=True,
        help_text="Account activation/suspension status",
    )

    # ─── PROFILE ──────────────────────────────────────────────
    avatar = models.ImageField(upload_to='avatars/users/', blank=True, null=True)
    middle_name = models.CharField(
        max_length=150,
        blank=True,
        null=True,
        help_text='Second given name (middle name)',
    )
    referral_code = models.CharField(max_length=12, unique=True, default=generate_referral_code, editable=False)
    referred_by = models.ForeignKey(
        'self',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='referrals',
    )

    # ─── AUDIT / SECURITY ─────────────────────────────────────
    last_login_ip = models.GenericIPAddressField(null=True, blank=True)
    last_seen = models.DateTimeField(null=True, blank=True)
    device_count = models.PositiveIntegerField(default=0)

    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'
        indexes = [
            models.Index(fields=['phone']),
            models.Index(fields=['role']),
            models.Index(fields=['national_id']),
            models.Index(fields=['email']),
            models.Index(fields=['account_status']),
            models.Index(fields=['kyc_status']),
        ]

    def save(self, *args, **kwargs):
        if self.phone:
            try:
                self.phone = normalize_phone_number(self.phone)
            except Exception:
                pass
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.phone} ({self.get_role_display()})"

    # ─── PROPERTIES ──────────────────────────────────────────────

    @property
    def full_name(self) -> str:
        parts = [self.first_name.strip() if self.first_name else '']
        if self.middle_name:
            parts.append(self.middle_name.strip())
        if self.last_name:
            parts.append(self.last_name.strip())
        return ' '.join(p for p in parts if p)

    @property
    def display_name(self) -> str:
        full = self.full_name
        if full:
            return full
        return self.username or self.phone

    @property
    def is_farmer(self) -> bool:
        return self.role == Role.FARMER

    @property
    def is_buyer(self) -> bool:
        return self.role == Role.BUYER

    @property
    def is_transport_provider(self) -> bool:
        return self.role == Role.TRANSPORT_PROVIDER

    @property
    def is_retailer(self) -> bool:
        return self.role == Role.RETAILER

    @property
    def is_active_account(self) -> bool:
        return self.account_status in [AccountStatus.VERIFIED, AccountStatus.PENDING]


# ────────────────────────────────────────────────────────────────
# FARMER PROFILE
# ────────────────────────────────────────────────────────────────

class FarmerProfile(BaseModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='farmer_profile')

    # ─── LOCATION (split GPS) ──────────────────────────────────
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        help_text="Farm GPS latitude",
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        help_text="Farm GPS longitude",
    )

    # ─── LOCATION HIERARCHY ────────────────────────────────────
    county = models.CharField(max_length=50, blank=True, help_text="County")
    sub_county = models.CharField(max_length=50, blank=True, help_text="Sub-county")
    ward = models.CharField(max_length=50, blank=True, help_text="Ward")
    village = models.CharField(max_length=50, blank=True, help_text="Village")

    # ─── COOPERATIVE ────────────────────────────────────────────
    cooperative = models.CharField(
        max_length=100,
        blank=True,
        help_text='Cooperative or group affiliation for the farmer',
    )
    coop_verified = models.BooleanField(
        default=False,
        help_text='Admin-verified cooperative endorsement',
    )

    # ─── PAYMENT ────────────────────────────────────────────────
    bank_account = models.CharField(max_length=50, blank=True, help_text='Bank account number')
    mpesa_number = models.CharField(
        max_length=15,
        blank=True,
        validators=[validate_phone_number],
        help_text='M-Pesa number for the farmer',
    )

    # ─── METRICS ────────────────────────────────────────────────
    total_sales = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    rating = models.FloatField(
        default=5.0,
        validators=[MinValueValidator(1.0), MaxValueValidator(5.0)],
        help_text="Average buyer rating 1-5",
    )
    rating_count = models.PositiveIntegerField(default=0, help_text="Number of ratings received")
    total_orders = models.PositiveIntegerField(default=0)

    # ─── BACKWARD COMPATIBILITY ────────────────────────────────
    @property
    def farm_gps(self) -> str:
        if self.latitude is not None and self.longitude is not None:
            return f"{self.latitude},{self.longitude}"
        return ""

    @farm_gps.setter
    def farm_gps(self, value):
        if value and ',' in value:
            try:
                lat, lng = value.split(',')
                self.latitude = float(lat.strip())
                self.longitude = float(lng.strip())
            except (ValueError, TypeError):
                pass

    class Meta:
        db_table = 'farmer_profiles'
        verbose_name = 'Farmer Profile'
        verbose_name_plural = 'Farmer Profiles'

    def __str__(self):
        return f"Farmer: {self.user.phone}"


# ────────────────────────────────────────────────────────────────
# TRANSPORT PROVIDER PROFILE
# ────────────────────────────────────────────────────────────────

class TransportProviderProfile(BaseModel):
    VEHICLE_TYPES = [
        ('motorcycle', 'Motorcycle'),
        ('pickup', 'Pickup Truck'),
        ('lorry', 'Lorry'),
        ('van', 'Van'),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='transport_profile')

    # ─── VEHICLE ────────────────────────────────────────────────
    vehicle_type = models.CharField(max_length=20, choices=VEHICLE_TYPES, blank=True)
    capacity_kg = models.PositiveIntegerField(
        default=100,
        validators=[MinValueValidator(1)],
        help_text='Vehicle capacity in kilograms',
    )
    license_plate = models.CharField(max_length=20, blank=True)
    driver_license = models.CharField(max_length=50, blank=True)

    # ─── PAYMENT ────────────────────────────────────────────────
    bank_account = models.CharField(
        max_length=50,
        blank=True,
        help_text='Bank account number for transport provider payouts',
    )

    # ─── DEPOSIT & APPROVAL ────────────────────────────────────
    deposit_paid = models.BooleanField(default=False)
    deposit_transaction_id = models.CharField(max_length=50, blank=True)
    is_approved = models.BooleanField(
        default=False,
        help_text='Admin approval after deposit verification',
    )

    # ─── RATING ──────────────────────────────────────────────────
    rating = models.FloatField(
        default=5.0,
        validators=[MinValueValidator(1.0), MaxValueValidator(5.0)],
        help_text="Provider rating 1-5",
    )
    rating_count = models.PositiveIntegerField(default=0, help_text="Number of ratings received")
    total_deliveries = models.PositiveIntegerField(default=0)

    # ─── DYNAMIC PRICING ────────────────────────────────────────
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

    # ─── LIVE TRACKING ──────────────────────────────────────────
    current_latitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True,
        help_text="Current provider GPS latitude"
    )
    current_longitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True,
        help_text="Current provider GPS longitude"
    )
    is_online = models.BooleanField(default=False, help_text="Provider is online and accepting orders")
    available = models.BooleanField(default=True, help_text="Available to accept new orders")
    current_order = models.ForeignKey(
        'orders.Order',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='active_provider',
        help_text="Currently assigned order (if any)"
    )
    last_location_update = models.DateTimeField(null=True, blank=True)

    # ── Reliability metrics (cached) ───────────────────────────
    on_time_percentage = models.DecimalField(max_digits=5, decimal_places=2, default=100.0)
    acceptance_rate = models.DecimalField(max_digits=5, decimal_places=2, default=100.0)
    completion_rate = models.DecimalField(max_digits=5, decimal_places=2, default=100.0)

    def update_reliability_metrics(self):
        from apps.logistics.models import Trip

        total_offered = Trip.objects.filter(provider=self).count()
        total_accepted = Trip.objects.filter(provider=self, status__in=['accepted', 'picked_up', 'delivered']).count()
        total_delivered = Trip.objects.filter(provider=self, status='delivered').count()

        on_time = Trip.objects.filter(
            provider=self,
            status='delivered',
            delivered_at__lte=models.F('order__scheduled_date')
        ).count()

        self.acceptance_rate = (total_accepted / total_offered * 100) if total_offered > 0 else 0
        self.completion_rate = (total_delivered / total_accepted * 100) if total_accepted > 0 else 0
        self.on_time_percentage = (on_time / total_delivered * 100) if total_delivered > 0 else 100.0
        self.save(update_fields=['acceptance_rate', 'completion_rate', 'on_time_percentage'])

    class Meta:
        db_table = 'transport_provider_profiles'
        verbose_name = 'Transport Provider Profile'
        verbose_name_plural = 'Transport Provider Profiles'

    def __str__(self):
        return f"Provider: {self.user.phone} ({self.vehicle_type or 'unassigned'})"


# ────────────────────────────────────────────────────────────────
# BUYER PROFILE
# ────────────────────────────────────────────────────────────────

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


# ────────────────────────────────────────────────────────────────
# RETAILER PROFILE
# ────────────────────────────────────────────────────────────────

class RetailerProfile(BaseModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='retailer_profile')

    # ─── BUSINESS INFO ──────────────────────────────────────────
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

    # ─── NEW FIELDS ──────────────────────────────────────────────
    business_registration_number = models.CharField(
        max_length=50,
        blank=True,
        help_text="Official business registration number",
    )
    business_logo = models.ImageField(
        upload_to='business_logos/',
        blank=True,
        null=True,
        help_text="Retailer business logo",
    )
    latitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True,
        help_text="Business location latitude",
    )
    longitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True,
        help_text="Business location longitude",
    )

    class Meta:
        db_table = 'retailer_profiles'
        verbose_name = 'Retailer Profile'
        verbose_name_plural = 'Retailer Profiles'

    def __str__(self):
        return f"Retailer: {self.business_name or self.user.phone}"