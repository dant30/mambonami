# backend/django_admin/apps/users/serializers/user_serializer.py
import logging
import json
from django.db import IntegrityError, transaction
from django.conf import settings
from django.utils import timezone
from rest_framework import serializers


def _normalize_vehicle_type(value):
    if not value:
        return ''
    normalized = str(value).strip().lower()
    if normalized in {'pickup', 'pickup truck', 'pick up'}:
        return 'pickup'
    if normalized in {'motorcycle', 'motor bike', 'bike'}:
        return 'motorcycle'
    if normalized in {'lorry', 'truck'}:
        return 'lorry'
    if normalized in {'van', 'mini van'}:
        return 'van'
    return normalized


from django.contrib.auth.password_validation import validate_password
from django.contrib.auth.hashers import make_password
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
from ..models import PendingRegistration

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


class RegistrationStartSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    role = serializers.ChoiceField(choices=Role.choices)
    username = serializers.CharField(max_length=150)
    password = serializers.CharField(write_only=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True)
    full_name = serializers.CharField(required=False, allow_blank=True)
    owner_full_name = serializers.CharField(required=False, allow_blank=True)
    email = serializers.EmailField(required=False, allow_blank=True)
    delivery_address = serializers.CharField(required=False, allow_blank=True)
    latitude = serializers.DecimalField(max_digits=9, decimal_places=6, required=False, allow_null=True)
    longitude = serializers.DecimalField(max_digits=9, decimal_places=6, required=False, allow_null=True)
    mpesa_number = serializers.CharField(required=False, allow_blank=True)
    vehicle_type = serializers.CharField(required=False, allow_blank=True)
    license_plate = serializers.CharField(required=False, allow_blank=True)
    business_name = serializers.CharField(required=False, allow_blank=True)
    business_address = serializers.CharField(required=False, allow_blank=True)
    bank_account = serializers.CharField(required=False, allow_blank=True)

    def validate_phone(self, value):
        phone = normalize_phone_number(value)
        if User.objects.filter(phone=phone).exists():
            raise serializers.ValidationError('User with this phone already exists.')
        return phone

    def validate(self, attrs):
        if attrs['password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        return attrs

    def save(self):
        from core.cache import RedisCache
        from core.utils import generate_otp
        from apps.notifications.services.sms import send_otp_message

        data = dict(self.validated_data)
        password = data.pop('password')
        data.pop('confirm_password', None)
        phone = data['phone']
        otp = generate_otp()
        registration_data = json.loads(json.dumps(data, default=str))
        pending = PendingRegistration.objects.create(
            phone=phone,
            role=data['role'],
            registration_data=registration_data,
            password_hash=make_password(password),
            otp_hash=make_password(otp),
            otp_expires_at=timezone.now() + timezone.timedelta(seconds=settings.OTP_EXPIRY_SECONDS),
        )
        result = send_otp_message(phone, otp)
        if result.get('status') != 'success':
            pending.delete()
            raise serializers.ValidationError({'detail': result.get('error') or result.get('message') or 'Could not send OTP right now.'})
        return {'registration_id': str(pending.registration_id), 'phone': phone, 'role': data['role'], 'expires_in': settings.OTP_EXPIRY_SECONDS, 'otp_sent': True}


class RegistrationVerifySerializer(serializers.Serializer):
    registration_id = serializers.UUIDField()
    otp = serializers.CharField(min_length=6, max_length=6)

    def validate(self, attrs):
        pending = PendingRegistration.objects.filter(registration_id=attrs['registration_id'], status='pending').first()
        if not pending:
            raise serializers.ValidationError({'registration_id': 'Registration session is invalid or expired.'})
        if pending.is_expired():
            pending.status = 'expired'
            pending.save(update_fields=['status', 'updated_at'])
            raise serializers.ValidationError({'otp': 'This verification code has expired.'})
        if pending.attempt_count >= settings.OTP_MAX_ATTEMPTS:
            pending.status = 'blocked'
            pending.save(update_fields=['status', 'updated_at'])
            raise serializers.ValidationError({'otp': 'Too many attempts. Request a new code.'})
        if not pending.check_otp(attrs['otp']):
            pending.attempt_count += 1
            pending.save(update_fields=['attempt_count', 'updated_at'])
            raise serializers.ValidationError({'otp': 'Invalid verification code.'})
        attrs['pending'] = pending
        return attrs


class RegistrationResendSerializer(serializers.Serializer):
    registration_id = serializers.UUIDField()

    def save(self):
        from core.utils import generate_otp
        from apps.notifications.services.sms import send_otp_message

        pending = PendingRegistration.objects.filter(registration_id=self.validated_data['registration_id'], status='pending').first()
        if not pending or pending.is_expired():
            raise serializers.ValidationError({'registration_id': 'Registration session is expired.'})
        if pending.resend_count >= 5:
            raise serializers.ValidationError({'detail': 'Maximum resend limit reached.'})
        otp = generate_otp()
        pending.otp_hash = make_password(otp)
        pending.otp_expires_at = timezone.now() + timezone.timedelta(seconds=settings.OTP_EXPIRY_SECONDS)
        pending.resend_count += 1
        pending.attempt_count = 0
        pending.save(update_fields=['otp_hash', 'otp_expires_at', 'resend_count', 'attempt_count', 'updated_at'])
        result = send_otp_message(pending.phone, otp)
        if result.get('status') != 'success':
            raise serializers.ValidationError({'detail': result.get('error') or result.get('message') or 'Could not send OTP right now.'})
        return {'registration_id': str(pending.registration_id), 'phone': pending.phone, 'expires_in': settings.OTP_EXPIRY_SECONDS, 'otp_sent': True}


class PasswordResetCodeSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    otp = serializers.CharField(min_length=6, max_length=6)

    def validate(self, attrs):
        phone = normalize_phone_number(attrs['phone'])
        if not User.objects.filter(phone=phone).exists():
            raise serializers.ValidationError({'phone': 'User with this phone does not exist.'})
        cached_otp = RedisCache.get(f'password_reset_otp:{phone}')
        if not cached_otp or cached_otp != attrs['otp']:
            raise serializers.ValidationError({'otp': 'Invalid or expired OTP.'})
        attrs['phone'] = phone
        return attrs


class VerifyOTPSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    otp = serializers.CharField(min_length=6, max_length=6)
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
    vehicle_type = serializers.CharField(required=False, allow_blank=True)
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
        existing_user = User.objects.filter(phone=normalized_phone).first()
        if existing_user and existing_user.username != self.initial_data.get('username'):
            raise serializers.ValidationError('User with this phone already exists.')
        return normalized_phone

    def validate_username(self, value):
        existing_user = User.objects.filter(username=value).first()
        if existing_user:
            normalized_phone = None
            try:
                normalized_phone = normalize_phone_number(self.initial_data.get('phone', ''))
            except Exception:
                normalized_phone = None
            if normalized_phone and existing_user.phone == normalized_phone:
                return value
            raise serializers.ValidationError('Username already taken.')
        return value

    def validate(self, attrs):
        if attrs['password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})

        if attrs.get('role') == Role.TRANSPORT_PROVIDER:
            normalized_vehicle_type = _normalize_vehicle_type(attrs.get('vehicle_type'))
            allowed_types = {value for value, _ in TransportProviderProfile.VEHICLE_TYPES}
            if normalized_vehicle_type not in allowed_types:
                raise serializers.ValidationError({'vehicle_type': 'Invalid vehicle type.'})
            attrs['vehicle_type'] = normalized_vehicle_type

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
        vehicle_type = _normalize_vehicle_type(validated_data.pop('vehicle_type', ''))
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

        # Create or reuse the user for a duplicate verification retry.
        existing_user = User.objects.filter(phone=validated_data['phone']).first()
        if existing_user:
            if existing_user.username != validated_data['username'] or existing_user.role != validated_data['role']:
                raise serializers.ValidationError({'phone': 'User with this phone already exists.'})
            user = existing_user
        else:
            try:
                with transaction.atomic():
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
            except IntegrityError:
                logger.warning('IntegrityError while creating user during verify; attempting to fetch existing user for phone=%s', validated_data.get('phone'))
                user = User.objects.filter(phone=validated_data.get('phone')).first()
                if not user:
                    raise

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
            from apps.paybill.services.account_number import generate_transport_deposit_account
            generate_transport_deposit_account(transport_profile.id)

        elif user.role == Role.BUYER:
            buyer_profile, _ = BuyerProfile.objects.get_or_create(user=user)
            buyer_profile.delivery_address = delivery_address
            buyer_profile.delivery_instructions = delivery_instructions
            if bank_account:
                buyer_profile.bank_account = bank_account
            buyer_profile.save()

        elif user.role == Role.RETAILER:
            retailer_profile, _ = RetailerProfile.objects.get_or_create(user=user)
            retailer_profile.business_name = business_name or retailer_profile.business_name or ''
            retailer_profile.owner_full_name = (
                owner_full_name
                or full_name
                or retailer_profile.owner_full_name
                or user.get_full_name()
                or user.username
                or user.phone
            )
            retailer_profile.business_phone = business_phone or retailer_profile.business_phone or user.phone
            retailer_profile.business_email = business_email or retailer_profile.business_email or user.email or ''
            retailer_profile.business_address = business_address or retailer_profile.business_address or ''
            retailer_profile.business_type = business_type or retailer_profile.business_type or ''
            retailer_profile.kra_pin = kra_pin or retailer_profile.kra_pin or ''
            retailer_profile.business_registration_number = business_registration_number or retailer_profile.business_registration_number or ''
            if bank_account:
                retailer_profile.bank_account = bank_account
            retailer_profile.save()

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
    otp = serializers.CharField(min_length=6, max_length=6)
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
    full_name = serializers.CharField(read_only=True)
    display_name = serializers.CharField(read_only=True)
    verification_status = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            'id', 'phone', 'username', 'email', 'first_name', 'middle_name', 'last_name', 'national_id',
            'full_name', 'display_name', 'role', 'is_phone_verified', 'is_email_verified',
            'is_active', 'account_status', 'kyc_status', 'verification_status', 'avatar', 'avatar_url',
            'is_staff', 'is_superuser', 'date_joined', 'last_seen',
            'farm_profile', 'transport_profile', 'buyer_profile', 'retailer_profile',
        )
        read_only_fields = ('id', 'is_active', 'date_joined', 'is_staff', 'is_superuser', 'last_seen')

    def get_avatar_url(self, obj):
        if obj.avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.avatar.url)
        return None

    def get_verification_status(self, obj):
        return obj.kyc_status

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
                'bank_account': p.bank_account,
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
                'driver_license': p.driver_license,
                'deposit_paid': p.deposit_paid,
                'deposit_amount': 500,
                'deposit_account_number': f'DEP-TRANSPORT-{p.id}',
                'paybill_number': getattr(settings, 'MPESA_PAYBILL_NUMBER', '123456'),
                'deposit_transaction_id': p.deposit_transaction_id,
                'is_approved': p.is_approved,
                'rating': p.rating,
                'total_deliveries': p.total_deliveries,
                'bank_account': p.bank_account,
                'avatar_url': self._get_avatar_url(p),
                'base_rate_per_km': p.base_rate_per_km,
                'waiting_grace_minutes': p.waiting_grace_minutes,
                'waiting_rate_per_min': p.waiting_rate_per_min,
                'is_online': p.is_online,
                'available': p.available,
                'acceptance_rate': p.acceptance_rate,
                'completion_rate': p.completion_rate,
                'on_time_percentage': p.on_time_percentage,
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
        avatar = getattr(profile, 'avatar', None)
        if avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(avatar.url)
        return None


class LoginSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    password = serializers.CharField(write_only=True)

    def validate_phone(self, value):
        return normalize_phone_number(value)
