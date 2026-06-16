# backend/django_admin/apps/users/serializers/admin_serializers.py
from rest_framework import serializers

from ..models import FarmerProfile, TransportProviderProfile, User


class FarmerAdminSerializer(serializers.ModelSerializer):
    user_phone = serializers.CharField(source='user.phone', read_only=True)
    user_username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = FarmerProfile
        fields = (
            'id', 'user', 'user_phone', 'user_username', 'farm_gps', 'coop_verified',
            'bank_account', 'mpesa_number', 'total_sales',
        )
        read_only_fields = ('id', 'user', 'user_phone', 'user_username', 'total_sales')


class TransportProviderAdminSerializer(serializers.ModelSerializer):
    user_phone = serializers.CharField(source='user.phone', read_only=True)
    user_username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = TransportProviderProfile
        fields = (
            'id', 'user', 'user_phone', 'user_username', 'vehicle_type', 'capacity_kg',
            'license_plate', 'driver_license', 'deposit_paid', 'is_approved', 'rating',
            'total_deliveries', 'base_rate_per_km', 'waiting_grace_minutes', 'waiting_rate_per_min',
        )
        read_only_fields = ('id', 'user', 'user_phone', 'user_username', 'rating', 'total_deliveries')


class UserAdminSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            'id', 'phone', 'username', 'role', 'email', 'is_active', 'is_staff',
            'is_superuser', 'is_phone_verified', 'date_joined',
        )
        read_only_fields = ('id', 'phone', 'date_joined')