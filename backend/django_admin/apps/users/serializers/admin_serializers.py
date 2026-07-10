# backend/django_admin/apps/users/serializers/admin_serializers.py
from rest_framework import serializers

from ..models import FarmerProfile, TransportProviderProfile, User


class FarmerAdminSerializer(serializers.ModelSerializer):
    user_phone = serializers.CharField(source='user.phone', read_only=True)
    user_username = serializers.CharField(source='user.username', read_only=True)
    avatar_url = serializers.SerializerMethodField()

    class Meta:
        model = FarmerProfile
        fields = (
            'id', 'user', 'user_phone', 'user_username', 'farm_gps', 'coop_verified',
            'bank_account', 'mpesa_number', 'total_sales', 'rating', 'total_orders',
            'avatar', 'avatar_url',
        )
        read_only_fields = ('id', 'user', 'user_phone', 'user_username', 'total_sales', 'rating', 'total_orders')

    def get_avatar_url(self, obj):
        if obj.avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.avatar.url)
        return None


class TransportProviderAdminSerializer(serializers.ModelSerializer):
    user_phone = serializers.CharField(source='user.phone', read_only=True)
    user_username = serializers.CharField(source='user.username', read_only=True)
    avatar_url = serializers.SerializerMethodField()

    class Meta:
        model = TransportProviderProfile
        fields = (
            'id', 'user', 'user_phone', 'user_username', 'vehicle_type', 'capacity_kg',
            'license_plate', 'driver_license', 'deposit_paid', 'is_approved', 'rating',
            'total_deliveries', 'base_rate_per_km', 'waiting_grace_minutes', 'waiting_rate_per_min',
            'avatar', 'avatar_url',
        )
        read_only_fields = ('id', 'user', 'user_phone', 'user_username', 'rating', 'total_deliveries')

    def get_avatar_url(self, obj):
        if obj.avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.avatar.url)
        return None


class UserAdminSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(source='full_name', read_only=True)
    display_name = serializers.CharField(source='display_name', read_only=True)
    avatar_url = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            'id', 'phone', 'username', 'first_name', 'middle_name', 'last_name',
            'full_name', 'display_name', 'role', 'email', 'is_active', 'is_staff',
            'is_superuser', 'is_phone_verified', 'is_email_verified', 'is_id_verified',
            'avatar', 'avatar_url', 'date_joined',
        )
        read_only_fields = ('id', 'phone', 'date_joined')

    def get_avatar_url(self, obj):
        if obj.avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.avatar.url)
        return None