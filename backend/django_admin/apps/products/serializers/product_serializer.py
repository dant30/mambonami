# backend/django_admin/apps/products/serializers/product_serializer.py
from rest_framework import serializers
from decimal import Decimal
from datetime import date
import json
from ..models import BulkPriceTier, Product, ProductCategory, WishlistItem
from core.utils import calculate_distance

class ProductCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductCategory
        fields = ('id', 'code', 'name')


class BulkPriceTierSerializer(serializers.ModelSerializer):
    class Meta:
        model = BulkPriceTier
        fields = ('id', 'buyer_role', 'minimum_quantity', 'unit_price')
        read_only_fields = fields

class ProductSerializer(serializers.ModelSerializer):
    farmer_phone = serializers.CharField(source='farmer.user.phone', read_only=True)
    farmer_name = serializers.CharField(source='farmer.user.display_name', read_only=True)
    farmer_verified = serializers.BooleanField(source='farmer.coop_verified', read_only=True)
    farmer_rating = serializers.FloatField(source='farmer.rating', read_only=True)
    category_detail = ProductCategorySerializer(source='category', read_only=True)
    remaining_shelf_life = serializers.SerializerMethodField()
    image_url = serializers.SerializerMethodField()
    distance_km = serializers.SerializerMethodField()
    bulk_price_tiers = BulkPriceTierSerializer(many=True, read_only=True)

    class Meta:
        model = Product
        fields = (
            'id', 'uuid', 'sku', 'farmer', 'farmer_phone', 'farmer_name',
            'farmer_verified', 'farmer_rating',
            'category', 'category_detail', 'name', 'variety', 'price_per_unit',
            'available_quantity', 'reserved_quantity', 'unit', 'harvest_date', 'shelf_life_days',
            'expiry_date', 'is_organic', 'remaining_shelf_life', 'is_active', 'image',
            'image_url', 'description',
            'pickup_lat', 'pickup_lng', 'weight_per_unit',
            'rating', 'review_count', 'wishlist_count',
            'bulk_price_tiers',
            'distance_km',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'uuid', 'sku', 'expiry_date', 'created_at', 'updated_at',
                            'rating', 'review_count', 'wishlist_count')

    def get_remaining_shelf_life(self, obj):
        if obj.harvest_date:
            days_passed = (date.today() - obj.harvest_date).days
            remaining = max(0, obj.shelf_life_days - days_passed)
            return remaining
        return 0

    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)
        return None

    def get_distance_km(self, obj):
        if not (obj.pickup_lat and obj.pickup_lng):
            return None
        buyer_lat = self.context.get('buyer_lat')
        buyer_lng = self.context.get('buyer_lng')
        if buyer_lat is None or buyer_lng is None:
            return None
        try:
            distance = calculate_distance(
                float(buyer_lat), float(buyer_lng),
                float(obj.pickup_lat), float(obj.pickup_lng)
            )
            return round(distance, 2)
        except Exception:
            return None

    def validate(self, attrs):
        if attrs.get('harvest_date') and attrs['harvest_date'] > date.today():
            raise serializers.ValidationError({"harvest_date": "Harvest date cannot be in the future."})
        return attrs


class BulkPriceTierInputListSerializer(serializers.ListSerializer):
    def to_internal_value(self, data):
        if isinstance(data, str):
            try:
                data = json.loads(data)
            except json.JSONDecodeError as exc:
                raise serializers.ValidationError('Enter valid JSON for bulk price tiers.') from exc
        return super().to_internal_value(data)


class BulkPriceTierInputSerializer(serializers.Serializer):
    buyer_role = serializers.ChoiceField(choices=BulkPriceTier.BUYER_ROLE_CHOICES, default='any')
    minimum_quantity = serializers.DecimalField(max_digits=12, decimal_places=2, min_value=Decimal('0.01'))
    unit_price = serializers.DecimalField(max_digits=10, decimal_places=2, min_value=Decimal('0.01'))

    class Meta:
        list_serializer_class = BulkPriceTierInputListSerializer


class ProductCreateUpdateSerializer(serializers.ModelSerializer):
    bulk_price_tiers = BulkPriceTierInputSerializer(many=True, required=False, write_only=True)

    class Meta:
        model = Product
        fields = (
            'sku', 'category', 'name', 'variety', 'price_per_unit', 'available_quantity',
            'reserved_quantity', 'unit', 'harvest_date', 'shelf_life_days', 'expiry_date',
            'is_organic', 'image', 'description', 'is_active', 'pickup_lat', 'pickup_lng',
            'weight_per_unit', 'bulk_price_tiers'
        )
        read_only_fields = ('sku', 'expiry_date',)

    def validate_harvest_date(self, value):
        if value > date.today():
            raise serializers.ValidationError("Harvest date cannot be in the future.")
        return value

    def validate_reserved_quantity(self, value):
        if value < Decimal('0'):
            raise serializers.ValidationError("Reserved quantity must be non-negative.")
        return value

    def validate_pickup_lat(self, value):
        if value is None:
            return value
        if value < Decimal('-12.0') or value > Decimal('5.0'):
            raise serializers.ValidationError("Pickup latitude is out of expected bounds.")
        return value

    def validate_pickup_lng(self, value):
        if value is None:
            return value
        if value < Decimal('34.0') or value > Decimal('42.0'):
            raise serializers.ValidationError("Pickup longitude is out of expected bounds.")
        return value

    def validate_weight_per_unit(self, value):
        if value < Decimal('0'):
            raise serializers.ValidationError("Weight per unit must be non-negative.")
        return value

    def validate(self, attrs):
        available = attrs.get('available_quantity')
        reserved = attrs.get('reserved_quantity', 0)
        if available and reserved > available:
            raise serializers.ValidationError(
                {"reserved_quantity": "Reserved quantity cannot exceed available quantity."}
            )
        tiers = attrs.get('bulk_price_tiers')
        if tiers is not None:
            seen = set()
            for tier in tiers:
                key = (tier['buyer_role'], tier['minimum_quantity'])
                if key in seen:
                    raise serializers.ValidationError({'bulk_price_tiers': 'Bulk price tiers must have unique buyer roles and minimum quantities.'})
                seen.add(key)
        return attrs


class WishlistItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)

    class Meta:
        model = WishlistItem
        fields = ('id', 'product', 'created_at')