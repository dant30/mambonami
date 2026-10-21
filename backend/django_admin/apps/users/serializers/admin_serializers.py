from django.core.exceptions import ValidationError as DjangoValidationError
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from core.validators import normalize_phone_number
from ..models import FarmerProfile, TransportProviderProfile, BuyerProfile, RetailerProfile, Role, User
from .user_serializer import UserDetailSerializer

class FarmerAdminSerializer(serializers.ModelSerializer):
    user_phone = serializers.CharField(source='user.phone', read_only=True)
    user_username = serializers.CharField(source='user.username', read_only=True)
    farm_gps = serializers.CharField(read_only=True)

    class Meta:
        model = FarmerProfile
        fields = (
            'id', 'user', 'user_phone', 'user_username',
            'latitude', 'longitude', 'farm_gps',
            'county', 'sub_county', 'ward', 'village',
            'cooperative', 'coop_verified',
            'bank_account', 'mpesa_number',
            'total_sales', 'rating', 'rating_count', 'total_orders',
        )
        read_only_fields = ('id', 'user', 'user_phone', 'user_username', 'total_sales', 'rating', 'total_orders')


class TransportProviderAdminSerializer(serializers.ModelSerializer):
    user_phone = serializers.CharField(source='user.phone', read_only=True)
    user_username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = TransportProviderProfile
        fields = (
            'id', 'user', 'user_phone', 'user_username',
            'vehicle_type', 'capacity_kg', 'license_plate', 'driver_license',
            'bank_account', 'deposit_paid', 'deposit_transaction_id',
            'is_approved', 'rating', 'rating_count', 'total_deliveries',
            'base_rate_per_km', 'waiting_grace_minutes', 'waiting_rate_per_min',
            'current_latitude', 'current_longitude', 'is_online', 'available',
        )
        read_only_fields = ('id', 'user', 'user_phone', 'user_username', 'rating', 'total_deliveries')


class BuyerAdminSerializer(serializers.ModelSerializer):
    user_phone = serializers.CharField(source='user.phone', read_only=True)

    class Meta:
        model = BuyerProfile
        fields = (
            'id', 'user', 'user_phone',
            'delivery_address', 'delivery_instructions',
            'bank_account',
        )
        read_only_fields = ('id', 'user', 'user_phone')


class RetailerAdminSerializer(serializers.ModelSerializer):
    user_phone = serializers.CharField(source='user.phone', read_only=True)

    class Meta:
        model = RetailerProfile
        fields = (
            'id', 'user', 'user_phone',
            'business_name', 'owner_full_name',
            'business_phone', 'business_email',
            'business_address', 'business_type',
            'kra_pin', 'bank_account',
            'business_registration_number',
            'latitude', 'longitude',
        )
        read_only_fields = ('id', 'user', 'user_phone')


class UserAdminSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(read_only=True)
    display_name = serializers.CharField(read_only=True)
    avatar_url = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            'id', 'phone', 'username', 'first_name', 'middle_name', 'last_name',
            'full_name', 'display_name', 'role', 'email', 'is_active', 'is_staff',
            'is_superuser', 'is_phone_verified', 'is_email_verified',
            'account_status', 'kyc_status', 'avatar', 'avatar_url', 'date_joined',
            'last_seen', 'last_login_ip',
        )
        read_only_fields = ('id', 'phone', 'date_joined', 'is_staff', 'is_superuser')

    def get_avatar_url(self, obj):
        if obj.avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.avatar.url)
        return None


class UserAdminDetailSerializer(UserAdminSerializer):
    national_id = serializers.CharField(read_only=True, allow_null=True)
    referral_code = serializers.CharField(read_only=True)
    role_profile = serializers.SerializerMethodField()

    class Meta(UserAdminSerializer.Meta):
        fields = UserAdminSerializer.Meta.fields + ('national_id', 'referral_code', 'role_profile')
        read_only_fields = UserAdminSerializer.Meta.read_only_fields + ('national_id', 'referral_code', 'role_profile')

    def get_role_profile(self, obj):
        profile_field = {
            Role.FARMER: 'farm_profile',
            Role.TRANSPORT_PROVIDER: 'transport_profile',
            Role.BUYER: 'buyer_profile',
            Role.RETAILER: 'retailer_profile',
        }.get(obj.role)
        if not profile_field:
            return None
        user_details = UserDetailSerializer(obj, context=self.context).data
        return user_details.get(profile_field)


class StaffAdminSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, allow_blank=True, min_length=8)
    display_name = serializers.CharField(read_only=True)

    class Meta:
        model = User
        fields = (
            'id', 'phone', 'username', 'first_name', 'middle_name', 'last_name',
            'display_name', 'email', 'password', 'date_joined', 'is_active',
            'is_staff', 'is_superuser', 'role', 'last_seen',
        )
        read_only_fields = ('id', 'date_joined', 'is_active', 'is_staff', 'is_superuser', 'role', 'last_seen')

    def validate_phone(self, value):
        try:
            normalized = normalize_phone_number(value)
        except (DjangoValidationError, TypeError, ValueError) as exc:
            detail = exc.messages if isinstance(exc, DjangoValidationError) else str(exc)
            raise serializers.ValidationError(detail) from exc

        existing = User.objects.filter(phone=normalized)
        if self.instance:
            existing = existing.exclude(pk=self.instance.pk)
        if existing.exists():
            raise serializers.ValidationError('A user with this phone number already exists.')
        return normalized

    def validate(self, attrs):
        if self.instance is None and not attrs.get('password'):
            raise serializers.ValidationError({'password': 'A password is required when creating a staff account.'})
        password = attrs.get('password')
        if password:
            candidate = self.instance or User(
                username=attrs.get('username', ''),
                phone=attrs.get('phone', ''),
                email=attrs.get('email', ''),
            )
            try:
                validate_password(password, user=candidate)
            except DjangoValidationError as exc:
                raise serializers.ValidationError({'password': exc.messages}) from exc
        return attrs

    def create(self, validated_data):
        password = validated_data.pop('password')
        return User.objects.create_user(
            password=password,
            role=Role.BUYER,
            is_staff=True,
            **validated_data,
        )

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        for field, value in validated_data.items():
            setattr(instance, field, value)
        if password:
            instance.set_password(password)
        instance.save()
        return instance