from rest_framework import serializers
from ..models import FarmerProfile, TransportProviderProfile, BuyerProfile, RetailerProfile, User

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