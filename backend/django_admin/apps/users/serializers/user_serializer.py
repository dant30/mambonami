# backend/django_admin/apps/users/serializers/user_serializer.py
import logging
from django.conf import settings
from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from core.cache import RedisCache, cache_otp, delete_otp, get_otp
from core.utils import generate_otp
from core.validators import normalize_phone_number, validate_phone_number
from apps.notifications.services.sms import send_otp_message
from ..models import (
    User,
    Role,
    AccountStatus,
    KycStatus,
    FarmerProfile,
    TransportProviderProfile,
    BuyerProfile,
    RetailerProfile,
)

logger = logging.getLogger(__name__)


class RegisterInitSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    role = serializers.ChoiceField(choices=Role.choices)

    def validate_phone(self, value):
        normalized_phone = normalize_phone_number(value)
        if User.objects.filter(phone=normalized_phone).exists():
            raise serializers.ValidationError('User with this phone already exists.')
        return normalized_phone

    def save(self):
        phone = self.validated_data['phone']
        otp = generate_otp()
        cache_otp(phone, otp)
        RedisCache.set(f'otp_attempts:{phone}', 0, timeout=settings.OTP_EXPIRY_SECONDS)
        send_otp_message(phone, otp)
        return {'message': 'OTP sent'}


class VerifyOTPSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    otp = serializers.CharField(max_length=4)
    username = serializers.CharField(max_length=150)
    password = serializers.CharField(write_only=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True)
    role = serializers.ChoiceField(choices=Role.choices)

    # Profile fields
    full_name = serializers.CharField(required=False, allow_blank=True)
    owner_full_name = serializers.CharField(required=False, allow_blank=True)
    national_id = serializers.CharField(required=False, allow_blank=True)
    email = serializers.EmailField(required=False, allow_blank=True)

    # Farmer specific
    latitude = serializers.DecimalField(max_digits=9, decimal_places=6, required=False, allow_null=True)
    longitude = serializers.DecimalField(max_digits=9, decimal_places=6, required=False, allow_null=True)
    county = serializers.CharField(required=False, allow_blank=True)
    sub_county = serializers.CharField(required=False, allow_blank=True)
    ward = serializers.CharField(required=False, allow_blank=True)
    village = serializers.CharField(required=False, allow_blank=True)
    mpesa_number = serializers.CharField(required=False, allow_blank=True)
    cooperative = serializers.CharField(required=False, allow_blank=True)

    # Transport provider specific
    vehicle_type = serializers.ChoiceField(
        choices=TransportProviderProfile.VEHICLE_TYPES,
        required=False,
        allow_blank=True,
    )
    license_plate = serializers.CharField(required=False, allow_blank=True)
    driver_license = serializers.CharField(required=False, allow_blank=True)

    # Common
    bank_account = serializers.CharField(required=False, allow_blank=True)

    # Buyer specific
    delivery_address = serializers.CharField(required=False, allow_blank=True)
    delivery_instructions = serializers.CharField(required=False, allow_blank=True)

    # Retailer specific
    business_name = serializers.CharField(required=False, allow_blank=True)
    business_phone = serializers.CharField(required=False, allow_blank=True)
    business_email = serializers.EmailField(required=False, allow_blank=True)
    business_address = serializers.CharField(required=False, allow_blank=True)
    business_type = serializers.CharField(required=False, allow_blank=True)
    kra_pin = serializers.CharField(required=False, allow_blank=True)
    business_registration_number = serializers.CharField(required=False, allow_blank=True)

    def validate_phone(self, value):
        normalized_phone = normalize_phone_number(value)
        if User.objects.filter(phone=normalized_phone).exists():
            raise serializers.ValidationError('User with this phone already exists.')
        return normalized_phone

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError('Username already taken.')
        return value

    def validate(self, attrs):
        if attrs['password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})

        attempts_key = f'otp_attempts:{attrs["phone"]}'
        attempts = RedisCache.get(attempts_key) or 0
        max_attempts = getattr(settings, 'OTP_MAX_ATTEMPTS', 3)
        if attempts >= max_attempts:
            delete_otp(attrs['phone'])
            RedisCache.delete(attempts_key)
            raise serializers.ValidationError({'otp': 'Maximum OTP attempts exceeded. Please request a new code.'})

        cached_otp = get_otp(attrs['phone'])
        if not cached_otp or cached_otp != attrs['otp']:
            RedisCache.set(attempts_key, attempts + 1, timeout=settings.OTP_EXPIRY_SECONDS)
            raise serializers.ValidationError({'otp': 'Invalid or expired OTP.'})

        RedisCache.delete(attempts_key)

        role = attrs['role']
        if role == Role.FARMER:
            if not attrs.get('latitude') or not attrs.get('longitude') or not attrs.get('mpesa_number'):
                raise serializers.ValidationError('GPS coordinates and M-Pesa number are required for farmers.')
        elif role == Role.TRANSPORT_PROVIDER:
            if not attrs.get('vehicle_type') or not attrs.get('license_plate'):
                raise serializers.ValidationError('Vehicle type and license plate are required for transport providers.')
        elif role == Role.BUYER:
            if not attrs.get('delivery_address'):
                raise serializers.ValidationError('Delivery address is required for buyers.')
        elif role == Role.RETAILER:
            if not attrs.get('business_name') or not attrs.get('owner_full_name'):
                raise serializers.ValidationError('Business name and owner full name are required for retailers.')

        return attrs

    def create(self, validated_data):
        validated_data.pop('otp')
        validated_data.pop('confirm_password')

        # Extract optional fields
        email = validated_data.pop('email', None)
        full_name = validated_data.pop('full_name', None)
        owner_full_name = validated_data.pop('owner_full_name', None)
        national_id = validated_data.pop('national_id', None)
        latitude = validated_data.pop('latitude', None)
        longitude = validated_data.pop('longitude', None)
        county = validated_data.pop('county', '')
        sub_county = validated_data.pop('sub_county', '')
        ward = validated_data.pop('ward', '')
        village = validated_data.pop('village', '')
        mpesa_number = validated_data.pop('mpesa_number', None)
        cooperative = validated_data.pop('cooperative', '')
        vehicle_type = validated_data.pop('vehicle_type', '')
        license_plate = validated_data.pop('license_plate', '')
        driver_license = validated_data.pop('driver_license', '')
        bank_account = validated_data.pop('bank_account', '')
        delivery_address = validated_data.pop('delivery_address', '')
        delivery_instructions = validated_data.pop('delivery_instructions', '')
        business_name = validated_data.pop('business_name', '')
        business_phone = validated_data.pop('business_phone', '')
        business_email = validated_data.pop('business_email', '')
        business_address = validated_data.pop('business_address', '')
        business_type = validated_data.pop('business_type', '')
        kra_pin = validated_data.pop('kra_pin', '')
        business_registration_number = validated_data.pop('business_registration_number', '')

        # Create user
        user = User.objects.create_user(
            phone=validated_data['phone'],
            username=validated_data['username'],
            password=validated_data['password'],
            role=validated_data['role'],
            email=email,
            national_id=national_id,
            is_phone_verified=True,
            account_status=AccountStatus.PENDING,
            kyc_status=KycStatus.PENDING,
        )

        # Set name
        if full_name and user.role in [Role.FARMER, Role.BUYER, Role.TRANSPORT_PROVIDER]:
            parts = full_name.split(' ', 1)
            user.first_name = parts[0]
            if len(parts) > 1:
                user.last_name = parts[1]
            user.save(update_fields=['first_name', 'last_name'])
        elif owner_full_name and user.role == Role.RETAILER:
            parts = owner_full_name.split(' ', 1)
            user.first_name = parts[0]
            if len(parts) > 1:
                user.last_name = parts[1]
            user.save(update_fields=['first_name', 'last_name'])

        # Create role profile
        if user.role == Role.FARMER:
            farmer_profile, _ = FarmerProfile.objects.get_or_create(user=user)
            farmer_profile.latitude = latitude
            farmer_profile.longitude = longitude
            farmer_profile.county = county
            farmer_profile.sub_county = sub_county
            farmer_profile.ward = ward
            farmer_profile.village = village
            farmer_profile.mpesa_number = mpesa_number or user.phone
            farmer_profile.cooperative = cooperative
            farmer_profile.coop_verified = False
            if bank_account:
                farmer_profile.bank_account = bank_account
            farmer_profile.save()

        elif user.role == Role.TRANSPORT_PROVIDER:
            transport_profile, _ = TransportProviderProfile.objects.get_or_create(user=user)
            transport_profile.vehicle_type = vehicle_type
            transport_profile.license_plate = license_plate
            transport_profile.driver_license = driver_license
            if bank_account:
                transport_profile.bank_account = bank_account
            transport_profile.deposit_paid = False
            transport_profile.is_approved = False
            transport_profile.save()

        elif user.role == Role.BUYER:
            buyer_profile, _ = BuyerProfile.objects.get_or_create(user=user)
            buyer_profile.delivery_address = delivery_address
            buyer_profile.delivery_instructions = delivery_instructions
            if bank_account:
                buyer_profile.bank_account = bank_account
            buyer_profile.save()

        elif user.role == Role.RETAILER:
            retailer_profile, _ = RetailerProfile.objects.get_or_create(user=user)
            retailer_profile.business_name = business_name
            retailer_profile.owner_full_name = owner_full_name
            retailer_profile.business_phone = business_phone
            retailer_profile.business_email = business_email
            retailer_profile.business_address = business_address
            retailer_profile.business_type = business_type
            retailer_profile.kra_pin = kra_pin
            retailer_profile.business_registration_number = business_registration_number
            if bank_account:
                retailer_profile.bank_account = bank_account
            retailer_profile.save()

        delete_otp(validated_data['phone'])
        return user


# ─── Password Reset, Change Password (unchanged, but keep them) ───

class PasswordResetInitSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)

    def validate_phone(self, value):
        return normalize_phone_number(value)

    def save(self):
        phone = self.validated_data['phone']
        if User.objects.filter(phone=phone).exists():
            otp = generate_otp()
            RedisCache.set(f'password_reset_otp:{phone}', otp, timeout=settings.OTP_EXPIRY_SECONDS)
            RedisCache.set(f'password_reset_attempts:{phone}', 0, timeout=settings.OTP_EXPIRY_SECONDS)
            sms_result = send_otp_message(phone, otp)
            if sms_result.get('status') != 'success':
                RedisCache.delete(f'password_reset_otp:{phone}')
                RedisCache.delete(f'password_reset_attempts:{phone}')
                error = sms_result.get('error') or sms_result.get('message') or 'SMS gateway did not accept the OTP.'
                logger.warning('Password reset OTP SMS failed for %s: %s', phone, error)
                raise serializers.ValidationError({
                    'detail': f'Could not send OTP right now: {error}'
                })
        return {'message': 'If an account exists for this phone, a reset OTP has been sent.'}


class PasswordResetVerifySerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    otp = serializers.CharField(max_length=4)
    new_password = serializers.CharField(write_only=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True)

    def validate_phone(self, value):
        normalized_phone = normalize_phone_number(value)
        if not User.objects.filter(phone=normalized_phone).exists():
            raise serializers.ValidationError('User with this phone does not exist.')
        return normalized_phone

    def validate(self, attrs):
        if attrs['new_password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})

        attempts_key = f'password_reset_attempts:{attrs["phone"]}'
        attempts = RedisCache.get(attempts_key) or 0
        max_attempts = getattr(settings, 'OTP_MAX_ATTEMPTS', 3)
        if attempts >= max_attempts:
            RedisCache.delete(attempts_key)
            RedisCache.delete(f'password_reset_otp:{attrs["phone"]}')
            raise serializers.ValidationError({'otp': 'Maximum OTP attempts exceeded. Please request a new code.'})

        cached_otp = RedisCache.get(f'password_reset_otp:{attrs["phone"]}')
        if not cached_otp or cached_otp != attrs['otp']:
            RedisCache.set(attempts_key, attempts + 1, timeout=settings.OTP_EXPIRY_SECONDS)
            raise serializers.ValidationError({'otp': 'Invalid or expired OTP.'})

        RedisCache.delete(attempts_key)
        return attrs

    def save(self):
        phone = self.validated_data['phone']
        password = self.validated_data['new_password']
        user = User.objects.get(phone=phone)
        user.set_password(password)
        user.save(update_fields=['password'])
        RedisCache.delete(f'password_reset_otp:{phone}')
        return user


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        if attrs['new_password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        return attrs

    def save(self):
        user = self.context['request'].user
        if not user.check_password(self.validated_data['old_password']):
            raise serializers.ValidationError({'old_password': 'Current password is incorrect.'})
        user.set_password(self.validated_data['new_password'])
        user.save(update_fields=['password'])
        return user


class UserDetailSerializer(serializers.ModelSerializer):
    farm_profile = serializers.SerializerMethodField()
    transport_profile = serializers.SerializerMethodField()
    buyer_profile = serializers.SerializerMethodField()
    retailer_profile = serializers.SerializerMethodField()
    avatar_url = serializers.SerializerMethodField()
    full_name = serializers.CharField(source='full_name', read_only=True)
    display_name = serializers.CharField(source='display_name', read_only=True)

    class Meta:
        model = User
        fields = (
            'id', 'phone', 'username', 'email', 'first_name', 'middle_name', 'last_name',
            'full_name', 'display_name', 'role', 'is_phone_verified', 'is_email_verified',
            'is_id_verified', 'account_status', 'kyc_status', 'avatar', 'avatar_url',
            'is_staff', 'is_superuser', 'date_joined', 'last_seen',
            'farm_profile', 'transport_profile', 'buyer_profile', 'retailer_profile',
        )
        read_only_fields = ('id', 'date_joined', 'is_staff', 'is_superuser', 'last_seen')

    def get_avatar_url(self, obj):
        if obj.avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.avatar.url)
        return None

    def get_farm_profile(self, obj):
        if hasattr(obj, 'farmer_profile'):
            p = obj.farmer_profile
            return {
                'latitude': p.latitude,
                'longitude': p.longitude,
                'farm_gps': p.farm_gps,
                'county': p.county,
                'sub_county': p.sub_county,
                'ward': p.ward,
                'village': p.village,
                'cooperative': p.cooperative,
                'coop_verified': p.coop_verified,
                'mpesa_number': p.mpesa_number,
                'total_sales': p.total_sales,
                'rating': p.rating,
                'total_orders': p.total_orders,
                'avatar_url': self._get_avatar_url(p),
            }
        return None

    def get_transport_profile(self, obj):
        if hasattr(obj, 'transport_profile'):
            p = obj.transport_profile
            return {
                'vehicle_type': p.vehicle_type,
                'capacity_kg': p.capacity_kg,
                'license_plate': p.license_plate,
                'deposit_paid': p.deposit_paid,
                'is_approved': p.is_approved,
                'rating': p.rating,
                'total_deliveries': p.total_deliveries,
                'avatar_url': self._get_avatar_url(p),
                'base_rate_per_km': p.base_rate_per_km,
                'waiting_grace_minutes': p.waiting_grace_minutes,
                'waiting_rate_per_min': p.waiting_rate_per_min,
                'is_online': p.is_online,
                'available': p.available,
            }
        return None

    def get_buyer_profile(self, obj):
        if hasattr(obj, 'buyer_profile'):
            return {
                'delivery_address': obj.buyer_profile.delivery_address,
                'delivery_instructions': obj.buyer_profile.delivery_instructions,
                'bank_account': obj.buyer_profile.bank_account,
            }
        return None

    def get_retailer_profile(self, obj):
        if hasattr(obj, 'retailer_profile'):
            p = obj.retailer_profile
            return {
                'business_name': p.business_name,
                'owner_full_name': p.owner_full_name,
                'business_phone': p.business_phone,
                'business_email': p.business_email,
                'business_address': p.business_address,
                'business_type': p.business_type,
                'kra_pin': p.kra_pin,
                'bank_account': p.bank_account,
                'business_registration_number': p.business_registration_number,
                'latitude': p.latitude,
                'longitude': p.longitude,
            }
        return None

    def _get_avatar_url(self, profile):
        if profile.avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(profile.avatar.url)
        return None


class LoginSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    password = serializers.CharField(write_only=True)

    def validate_phone(self, value):
        return normalize_phone_number(value)