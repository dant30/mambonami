# backend/django_admin/apps/logistics/serializers/logistics_serializer.py
from rest_framework import serializers
from django.utils.timesince import timesince
from math import radians, cos, sin, asin, sqrt
from ..models import Trip
from apps.orders.serializers import OrderSerializer

def haversine_distance(lat1, lon1, lat2, lon2):
    """
    Calculate the great circle distance between two points 
    on the earth (specified in decimal degrees) in kilometers
    """
    # Convert decimal degrees to radians
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    
    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    km = 6371 * c
    return km

class TripSerializer(serializers.ModelSerializer):
    # ── Existing nested fields ──
    order_detail = OrderSerializer(source='order', read_only=True)
    provider_detail = serializers.SerializerMethodField()
    pickupLocation = serializers.SerializerMethodField()
    deliveryLocation = serializers.SerializerMethodField()
    distanceKm = serializers.SerializerMethodField()
    etaMinutes = serializers.SerializerMethodField()
    date = serializers.SerializerMethodField()

<<<<<<< HEAD
    class Meta:
        model = Trip
        fields = (
            'id', 'uuid', 'order', 'order_detail', 'provider', 'provider_detail',
            'status', 'pickup_lat', 'pickup_lng', 'delivery_lat', 'delivery_lng',
            'pickupLocation', 'deliveryLocation', 'distanceKm', 'etaMinutes',
            'agreed_fee', 'waiting_surcharge',
            'pickup_photo', 'delivery_photo', 'picked_up_at', 'delivered_at',
            'date', 'otp_code', 'otp_expires_at', 'otp_attempts', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at', 'otp_code', 'otp_expires_at', 'agreed_fee', 'waiting_surcharge')
=======
    # ── New computed display fields ──
    order_id = serializers.SerializerMethodField()
    fee = serializers.DecimalField(source='agreed_fee', decimal_places=2, max_digits=10)
    delivery_location = serializers.CharField(source='order.delivery_address', read_only=True)

    driver_name = serializers.CharField(source='provider.user.display_name', read_only=True)
    driver_phone = serializers.CharField(source='provider.user.phone', read_only=True)
    driver_avatar_url = serializers.SerializerMethodField()
    driver_rating = serializers.FloatField(source='provider.rating', read_only=True)
    vehicle_label = serializers.SerializerMethodField()

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
>>>>>>> b3899a6 (feat: backend code refactor)

    def get_provider_detail(self, obj):
        if obj.provider:
            return {
                'phone': obj.provider.user.phone,
                'vehicle_type': obj.provider.vehicle_type,
                'license_plate': obj.provider.license_plate,
                'rating': obj.provider.rating,
            }
        return None
    
    def get_pickupLocation(self, obj):
        """Return pickup location as address string. Falls back to coordinates."""
        if obj.order and obj.order.delivery_address:
            return obj.order.delivery_address
        if obj.pickup_lat and obj.pickup_lng:
            return f"{obj.pickup_lat},{obj.pickup_lng}"
        return "TBD"
    
    def get_deliveryLocation(self, obj):
        """Return delivery location as address string. Falls back to coordinates."""
        if obj.order and obj.order.delivery_address:
            return obj.order.delivery_address
        if obj.delivery_lat and obj.delivery_lng:
            return f"{obj.delivery_lat},{obj.delivery_lng}"
        return "TBD"
    
    def get_distanceKm(self, obj):
        """Calculate distance between pickup and delivery using Haversine formula."""
        if obj.pickup_lat and obj.pickup_lng and obj.delivery_lat and obj.delivery_lng:
            try:
                distance = haversine_distance(
                    float(obj.pickup_lat), float(obj.pickup_lng),
                    float(obj.delivery_lat), float(obj.delivery_lng)
                )
                return round(distance, 2)
            except:
                return None
        return None
    
    def get_etaMinutes(self, obj):
        """Estimate ETA based on distance and average speed (40 km/h in Kenya)."""
        distance = self.get_distanceKm(obj)
        if distance:
            # Assume average speed of 40 km/h
            hours = distance / 40
            minutes = int(hours * 60)
            return max(10, minutes)  # Minimum 10 minutes
        return None
    
    def get_date(self, obj):
        """Return formatted date of trip creation."""
        return obj.created_at.strftime('%d %b %Y')

    class Meta:
        model = Trip
        fields = (
            'id', 'uuid', 'order', 'order_detail', 'order_id',
            'provider', 'provider_detail',
            'status',
            'pickup_lat', 'pickup_lng', 'delivery_lat', 'delivery_lng',
            'pickup_address', 'distance_km', 'eta_minutes',
            'agreed_fee', 'fee', 'waiting_surcharge',
            'pickup_photo', 'delivery_photo',
            'accepted_at', 'arrived_at_farm', 'picked_up_at', 'delivered_at',
            'driver_name', 'driver_phone', 'driver_avatar_url', 'driver_rating',
            'vehicle_label', 'delivery_location',
            'otp_code', 'otp_expires_at', 'otp_attempts',
            'created_at', 'updated_at'
        )
        read_only_fields = (
            'id', 'uuid', 'created_at', 'updated_at',
            'otp_code', 'otp_expires_at', 'otp_attempts',
            'agreed_fee', 'waiting_surcharge', 'accepted_at',
            'distance_km', 'eta_minutes'   # these are computed/assigned programmatically
        )


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