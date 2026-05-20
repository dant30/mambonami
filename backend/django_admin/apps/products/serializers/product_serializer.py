# django_admin/apps/products/serializers/product_serializer.py
# backend/django_admin/apps/products/serializers/product_serializer.py
from rest_framework import serializers
from django.utils import timezone
from datetime import date
from ..models import Product, ProductCategory

class ProductCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductCategory
        fields = ('id', 'code', 'name', 'base_unit')

class ProductSerializer(serializers.ModelSerializer):
    farmer_phone = serializers.CharField(source='farmer.user.phone', read_only=True)
    farmer_name = serializers.CharField(source='farmer.user.username', read_only=True)
    category_detail = ProductCategorySerializer(source='category', read_only=True)
    remaining_shelf_life = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = (
            'id', 'uuid', 'farmer', 'farmer_phone', 'farmer_name',
            'category', 'category_detail', 'name', 'variety', 'price_per_unit',
            'available_quantity', 'unit', 'harvest_date', 'shelf_life_days',
            'remaining_shelf_life', 'is_active', 'image', 'description',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at')

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
            'category', 'name', 'variety', 'price_per_unit', 'available_quantity',
            'unit', 'harvest_date', 'shelf_life_days', 'image', 'description', 'is_active'
        )

    def validate_harvest_date(self, value):
        if value > date.today():
            raise serializers.ValidationError("Harvest date cannot be in the future.")
        return value