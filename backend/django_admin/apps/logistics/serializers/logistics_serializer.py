# backend/django_admin/apps/logistics/serializers/logistics_serializer.py
from rest_framework import serializers
from django.utils.timesince import timesince
from math import radians, cos, sin, asin, sqrt
from ..models import Trip, TripStatusHistory, TripLocationPing, TripMedia
from apps.orders.serializers import OrderSerializer


def haversine_distance(lat1, lon1, lat2, lon2):
    """Haversine distance as fallback when road distance is unavailable."""
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    km = 6371 * c
    return km


class TripStatusHistorySerializer(serializers.ModelSerializer):
    actor_phone = serializers.CharField(source='actor.phone', read_only=True, default=None)

    class Meta:
        model = TripStatusHistory
        fields = ('status', 'changed_at', 'location_lat', 'location_lng', 
                  'battery_level', 'speed_kmh', 'actor', 'actor_phone', 'source', 'note', 'ip_address')


class TripLocationPingSerializer(serializers.ModelSerializer):
    class Meta:
        model = TripLocationPing
        fields = ('id', 'latitude', 'longitude', 'heading', 'speed_kmh', 
                  'accuracy_m', 'altitude_m', 'battery_level', 'timestamp')


class TripMediaSerializer(serializers.ModelSerializer):
    uploaded_by_phone = serializers.CharField(source='uploaded_by.phone', read_only=True, default=None)
    image_url = serializers.SerializerMethodField()

    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)
        return None

    class Meta:
        model = TripMedia
        fields = ('id', 'media_type', 'image_url', 'uploaded_by', 'uploaded_by_phone', 
                  'uploaded_at', 'latitude', 'longitude', 'caption', 'is_verified')


class TripSerializer(serializers.ModelSerializer):
    # ── Nested relations ──
    order_detail = OrderSerializer(source='order', read_only=True)
    provider_detail = serializers.SerializerMethodField()
    status_history = TripStatusHistorySerializer(source='status_history', many=True, read_only=True)
    location_pings = TripLocationPingSerializer(source='location_pings', many=True, read_only=True)
    media = TripMediaSerializer(source='media', many=True, read_only=True)

    # ── Computed display fields ──
    order_id = serializers.SerializerMethodField()
    delivery_location = serializers.CharField(source='order.delivery_address', read_only=True)

    driver_name = serializers.CharField(source='provider.user.display_name', read_only=True)
    driver_phone = serializers.CharField(source='provider.user.phone', read_only=True)
    driver_avatar_url = serializers.SerializerMethodField()
    driver_rating = serializers.FloatField(source='provider.rating', read_only=True)
    vehicle_label = serializers.SerializerMethodField()

    # ── Timings ──
    total_duration_minutes = serializers.SerializerMethodField()
    pickup_delay_minutes = serializers.SerializerMethodField()
    driving_time_minutes = serializers.SerializerMethodField()

    def get_order_id(self, obj):
        return f"ORD-{obj.order.id}"

    def get_driver_avatar_url(self, obj):
        if obj.provider and obj.provider.avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.provider.avatar.url)
        return None

    def get_vehicle_label(self, obj):
        if obj.provider:
            return f"{obj.provider.get_vehicle_type_display()} · {obj.provider.license_plate}"
        return None

    def get_provider_detail(self, obj):
        if obj.provider:
            return {
                'phone': obj.provider.user.phone,
                'vehicle_type': obj.provider.vehicle_type,
                'license_plate': obj.provider.license_plate,
                'rating': obj.provider.rating,
                'on_time_percentage': obj.provider.on_time_percentage,
                'acceptance_rate': obj.provider.acceptance_rate,
                'completion_rate': obj.provider.completion_rate,
            }
        return None

    def get_total_duration_minutes(self, obj):
        if obj.completed_at and obj.accepted_at:
            delta = obj.completed_at - obj.accepted_at
            return int(delta.total_seconds() / 60)
        return None

    def get_pickup_delay_minutes(self, obj):
        if obj.picked_up_at and obj.arrived_pickup_at:
            delta = obj.picked_up_at - obj.arrived_pickup_at
            return max(0, int(delta.total_seconds() / 60))
        return 0

    def get_driving_time_minutes(self, obj):
        if obj.arrived_delivery_at and obj.left_pickup_at:
            delta = obj.arrived_delivery_at - obj.left_pickup_at
            return int(delta.total_seconds() / 60)
        return None

    class Meta:
        model = Trip
        fields = (
            'id', 'uuid', 'order', 'order_detail', 'order_id',
            'provider', 'provider_detail',
            'status',
            # Location
            'pickup_lat', 'pickup_lng', 'delivery_lat', 'delivery_lng',
            'current_lat', 'current_lng',
            'pickup_address', 'delivery_address',
            'straight_line_km', 'road_km', 'eta_minutes',
            # Fees
            'base_fee', 'distance_fee', 'weight_fee', 'waiting_fee', 'surge_fee',
            'commission', 'provider_payout', 'platform_fee', 'buyer_total',
            # Legacy (kept for compatibility)
            'agreed_fee', 'waiting_surcharge',
            # Vehicle snapshot
            'vehicle_type', 'vehicle_plate', 'vehicle_make', 'vehicle_model',
            # Timestamps
            'created_at_trip', 'offered_at', 'accepted_at',
            'started_navigation_pickup', 'arrived_pickup_at', 'picked_up_at',
            'left_pickup_at', 'started_navigation_delivery', 'arrived_delivery_at',
            'otp_verified_at', 'completed_at', 'cancelled_at', 'failed_at',
            # Audit
            'assigned_by', 'accepted_device', 'completed_device', 'ip_address',
            # Cancellation / failure
            'cancel_reason', 'cancelled_by', 'failure_reason',
            # Delivery
            'delivery_notes', 'buyer_signature',
            # Ratings
            'buyer_rating', 'provider_rating',
            # Driver info
            'driver_name', 'driver_phone', 'driver_avatar_url', 'driver_rating',
            'vehicle_label', 'delivery_location',
            # OTP
            'otp_hash', 'otp_expires_at', 'otp_attempts',
            # Nested
            'status_history', 'location_pings', 'media',
            # Computed timings
            'total_duration_minutes', 'pickup_delay_minutes', 'driving_time_minutes',
            'created_at', 'updated_at'
        )
        read_only_fields = (
            'id', 'uuid', 'created_at', 'updated_at',
            'created_at_trip', 'offered_at', 'accepted_at',
            'started_navigation_pickup', 'arrived_pickup_at', 'picked_up_at',
            'left_pickup_at', 'started_navigation_delivery', 'arrived_delivery_at',
            'otp_verified_at', 'completed_at', 'cancelled_at', 'failed_at',
            'otp_hash', 'otp_expires_at', 'otp_attempts',
            'status_history', 'location_pings', 'media',
            'total_duration_minutes', 'pickup_delay_minutes', 'driving_time_minutes'
        )


# ── Existing serializers (unchanged) ──
class TripAssignSerializer(serializers.Serializer):
    provider_id = serializers.IntegerField()
    order_id = serializers.IntegerField()


class TripPickupSerializer(serializers.Serializer):
    pickup_lat = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)
    pickup_lng = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)
    pickup_photo = serializers.ImageField(required=False)


class TripDeliverSerializer(serializers.Serializer):
    delivery_lat = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)
    delivery_lng = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)
    delivery_photo = serializers.ImageField(required=False)


class OTPVerifySerializer(serializers.Serializer):
    otp = serializers.CharField(max_length=6)


class TripLocationPingSerializer(serializers.Serializer):
    latitude = serializers.DecimalField(max_digits=9, decimal_places=6)
    longitude = serializers.DecimalField(max_digits=9, decimal_places=6)
    heading = serializers.IntegerField(min_value=0, max_value=359, required=False)
    speed_kmh = serializers.DecimalField(max_digits=5, decimal_places=2, required=False)
    accuracy_m = serializers.IntegerField(min_value=0, required=False)
    altitude_m = serializers.IntegerField(min_value=0, required=False)
    battery_level = serializers.IntegerField(min_value=0, max_value=100, required=False)


class TripMediaUploadSerializer(serializers.Serializer):
    media_type = serializers.ChoiceField(choices=TripMedia.MEDIA_TYPES)
    image = serializers.ImageField()
    latitude = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)
    longitude = serializers.DecimalField(max_digits=9, decimal_places=6, required=False)
    caption = serializers.CharField(max_length=255, required=False, allow_blank=True)