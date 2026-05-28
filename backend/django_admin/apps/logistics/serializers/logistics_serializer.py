# django_admin/apps/logistics/serializers/logistics_serializer.py
# backend/django_admin/apps/logistics/serializers/logistics_serializer.py
from rest_framework import serializers
from ..models import Trip
from apps.orders.serializers import OrderSerializer
from apps.users.serializers import UserDetailSerializer

class TripSerializer(serializers.ModelSerializer):
    order_detail = OrderSerializer(source='order', read_only=True)
    provider_detail = serializers.SerializerMethodField()

    class Meta:
        model = Trip
        fields = (
            'id', 'uuid', 'order', 'order_detail', 'provider', 'provider_detail',
            'status', 'pickup_lat', 'pickup_lng', 'delivery_lat', 'delivery_lng',
            'agreed_fee', 'waiting_surcharge',
            'pickup_photo', 'delivery_photo', 'picked_up_at', 'delivered_at',
            'otp_code', 'otp_expires_at', 'otp_attempts', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at', 'otp_code', 'otp_expires_at', 'agreed_fee', 'waiting_surcharge')

    def get_provider_detail(self, obj):
        if obj.provider:
            return {
                'phone': obj.provider.user.phone,
                'vehicle_type': obj.provider.vehicle_type,
                'license_plate': obj.provider.license_plate,
                'rating': obj.provider.rating,
            }
        return None


class TripAssignSerializer(serializers.Serializer):
    """Used to assign a transport provider to a trip."""
    provider_id = serializers.IntegerField()
    order_id = serializers.IntegerField()


class TripPickupSerializer(serializers.Serializer):
    """Provider marks pickup and uploads photo."""
    pickup_lat = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)
    pickup_lng = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)
    pickup_photo = serializers.ImageField(required=False)


class TripDeliverSerializer(serializers.Serializer):
    """Provider generates OTP; buyer verifies."""
    delivery_lat = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)
    delivery_lng = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)
    delivery_photo = serializers.ImageField(required=False)


class OTPVerifySerializer(serializers.Serializer):
    """Buyer enters OTP to confirm delivery."""
    otp = serializers.CharField(max_length=6)