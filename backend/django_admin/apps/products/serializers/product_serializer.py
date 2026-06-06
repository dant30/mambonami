# django_admin/apps/products/serializers/product_serializer.py
# backend/django_admin/apps/products/serializers/product_serializer.py
from rest_framework import serializers
from decimal import Decimal
from django.utils import timezone
from datetime import date
from ..models import Product, ProductCategory

class ProductCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductCategory
        fields = ('id', 'code', 'name')

class ProductSerializer(serializers.ModelSerializer):
    farmer_phone = serializers.CharField(source='farmer.user.phone', read_only=True)
    farmer_name = serializers.CharField(source='farmer.user.username', read_only=True)
    category_detail = ProductCategorySerializer(source='category', read_only=True)
    remaining_shelf_life = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = (
            'id', 'uuid', 'sku', 'farmer', 'farmer_phone', 'farmer_name',
            'category', 'category_detail', 'name', 'variety', 'price_per_unit',
            'available_quantity', 'reserved_quantity', 'unit', 'harvest_date', 'shelf_life_days',
            'expiry_date', 'is_organic', 'remaining_shelf_life', 'is_active', 'image', 'description',
            'pickup_lat', 'pickup_lng', 'weight_per_unit',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'uuid', 'sku', 'expiry_date', 'created_at', 'updated_at')

    def get_remaining_shelf_life(self, obj):
        if obj.harvest_date:
            days_passed = (date.today() - obj.harvest_date).days
            remaining = max(0, obj.shelf_life_days - days_passed)
            return remaining
        return 0

    def validate(self, attrs):
        # Ensure harvest date is not in the future
        if attrs.get('harvest_date') and attrs['harvest_date'] > date.today():
            raise serializers.ValidationError({"harvest_date": "Harvest date cannot be in the future."})
        return attrs

class ProductCreateUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = (
            'sku', 'category', 'name', 'variety', 'price_per_unit', 'available_quantity',
            'reserved_quantity', 'unit', 'harvest_date', 'shelf_life_days', 'expiry_date',
            'is_organic', 'image', 'description', 'is_active', 'pickup_lat', 'pickup_lng'
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
        if value < Decimal('-12.0') or value > Decimal('5.0'):
            raise serializers.ValidationError("Pickup latitude is out of expected bounds.")
        return value

    def validate_pickup_lng(self, value):
        if value < Decimal('34.0') or value > Decimal('42.0'):
            raise serializers.ValidationError("Pickup longitude is out of expected bounds.")
        return value

    def validate_weight_per_unit(self, value):
        if value < Decimal('0'):
            raise serializers.ValidationError("Weight per unit must be non-negative.")
        return value

    def validate(self, attrs):
        """Validate that reserved_quantity doesn't exceed available_quantity."""
        available = attrs.get('available_quantity')
        reserved = attrs.get('reserved_quantity', 0)
        
        if available and reserved > available:
            raise serializers.ValidationError(
                {"reserved_quantity": "Reserved quantity cannot exceed available quantity."}
            )
        return attrs
