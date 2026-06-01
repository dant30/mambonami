# backend/django_admin/apps/users/serializers/user_serializer.py
import logging
from django.conf import settings
from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from core.cache import RedisCache, cache_otp, delete_otp, get_otp
from core.utils import generate_otp
from core.validators import validate_phone_number
from ..models import User, FarmerProfile, TransportProviderProfile

logger = logging.getLogger(__name__)


def send_otp_message(phone: str, otp: str) -> None:
    message = f"Your Mambonami verification code is {otp}. It expires in 5 minutes."
    try:
        from apps.notifications.services.whatsapp import send_whatsapp_message
        send_whatsapp_message(phone, message)
    except Exception:
        logger.warning('OTP fallback for %s: %s', phone, otp)


class RegisterInitSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    role = serializers.ChoiceField(choices=User.ROLE_CHOICES)

    def validate_phone(self, value):
        validate_phone_number(value)
        if User.objects.filter(phone=value).exists():
            raise serializers.ValidationError('User with this phone already exists.')
        return value

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
    role = serializers.ChoiceField(choices=User.ROLE_CHOICES)
    email = serializers.EmailField(required=False, allow_blank=True)
    farm_gps = serializers.CharField(required=False, allow_blank=True)
    mpesa_number = serializers.CharField(required=False, allow_blank=True)
    vehicle_type = serializers.ChoiceField(
        choices=TransportProviderProfile.VEHICLE_TYPES,
        required=False,
        allow_blank=True,
    )
    license_plate = serializers.CharField(required=False, allow_blank=True)
    driver_license = serializers.CharField(required=False, allow_blank=True)

    def validate_phone(self, value):
        validate_phone_number(value)
        if User.objects.filter(phone=value).exists():
            raise serializers.ValidationError('User with this phone already exists.')
        return value

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

        if attrs['role'] == 'farmer':
            if not attrs.get('farm_gps') or not attrs.get('mpesa_number'):
                raise serializers.ValidationError('Farm GPS and M-Pesa number are required for farmers.')
        if attrs['role'] == 'transport_provider':
            if not attrs.get('vehicle_type') or not attrs.get('license_plate'):
                raise serializers.ValidationError('Vehicle type and license plate are required for transport providers.')

        return attrs

    def create(self, validated_data):
        validated_data.pop('otp')
        validated_data.pop('confirm_password')

        farm_gps = validated_data.pop('farm_gps', None)
        mpesa_number = validated_data.pop('mpesa_number', None)
        vehicle_type = validated_data.pop('vehicle_type', None)
        license_plate = validated_data.pop('license_plate', None)
        driver_license = validated_data.pop('driver_license', None)
        email = validated_data.pop('email', None)

        user = User.objects.create_user(
            phone=validated_data['phone'],
            username=validated_data['username'],
            password=validated_data['password'],
            role=validated_data['role'],
            email=email,
            is_phone_verified=True,
        )

        if user.role == 'farmer':
            farmer_profile, _ = FarmerProfile.objects.get_or_create(user=user)
            farmer_profile.farm_gps = farm_gps or ''
            farmer_profile.mpesa_number = mpesa_number or user.phone
            farmer_profile.coop_verified = False
            farmer_profile.save(update_fields=['farm_gps', 'mpesa_number', 'coop_verified'])
        elif user.role == 'transport_provider':
            transport_profile, _ = TransportProviderProfile.objects.get_or_create(user=user)
            transport_profile.vehicle_type = vehicle_type or ''
            transport_profile.license_plate = license_plate or ''
            transport_profile.driver_license = driver_license or ''
            transport_profile.deposit_paid = False
            transport_profile.is_approved = False
            transport_profile.save(update_fields=['vehicle_type', 'license_plate', 'driver_license', 'deposit_paid', 'is_approved'])

        delete_otp(validated_data['phone'])
        return user


class PasswordResetInitSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)

    def validate_phone(self, value):
        validate_phone_number(value)
        return value

    def save(self):
        phone = self.validated_data['phone']
        if User.objects.filter(phone=phone).exists():
            otp = generate_otp()
            RedisCache.set(f'password_reset_otp:{phone}', otp, timeout=settings.OTP_EXPIRY_SECONDS)
            RedisCache.set(f'password_reset_attempts:{phone}', 0, timeout=settings.OTP_EXPIRY_SECONDS)
            send_otp_message(phone, otp)
        return {'message': 'If an account exists for this phone, a reset OTP has been sent.'}


class PasswordResetVerifySerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    otp = serializers.CharField(max_length=4)
    new_password = serializers.CharField(write_only=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True)

    def validate_phone(self, value):
        validate_phone_number(value)
        if not User.objects.filter(phone=value).exists():
            raise serializers.ValidationError('User with this phone does not exist.')
        return value

    def validate(self, attrs):
        if attrs['new_password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})

        attempts_key = f'password_reset_attempts:{attrs['phone']}'
        attempts = RedisCache.get(attempts_key) or 0
        max_attempts = getattr(settings, 'OTP_MAX_ATTEMPTS', 3)
        if attempts >= max_attempts:
            RedisCache.delete(attempts_key)
            RedisCache.delete(f'password_reset_otp:{attrs['phone']}')
            raise serializers.ValidationError({'otp': 'Maximum OTP attempts exceeded. Please request a new code.'})

        cached_otp = RedisCache.get(f'password_reset_otp:{attrs['phone']}')
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


class UserDetailSerializer(serializers.ModelSerializer):
    farm_profile = serializers.SerializerMethodField()
    transport_profile = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            'id', 'phone', 'username', 'email', 'first_name', 'last_name', 'role',
            'is_phone_verified', 'date_joined', 'farm_profile', 'transport_profile',
        )

    def get_farm_profile(self, obj):
        if hasattr(obj, 'farmer_profile'):
            return {
                'farm_gps': obj.farmer_profile.farm_gps,
                'coop_verified': obj.farmer_profile.coop_verified,
                'mpesa_number': obj.farmer_profile.mpesa_number,
                'total_sales': obj.farmer_profile.total_sales,
            }
        return None

    def get_transport_profile(self, obj):
        if hasattr(obj, 'transport_profile'):
            return {
                'vehicle_type': obj.transport_profile.vehicle_type,
                'capacity_kg': obj.transport_profile.capacity_kg,
                'license_plate': obj.transport_profile.license_plate,
                'deposit_paid': obj.transport_profile.deposit_paid,
                'is_approved': obj.transport_profile.is_approved,
                'rating': obj.transport_profile.rating,
                'total_deliveries': obj.transport_profile.total_deliveries,
            }
        return None


class LoginSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=15)
    password = serializers.CharField(write_only=True)
