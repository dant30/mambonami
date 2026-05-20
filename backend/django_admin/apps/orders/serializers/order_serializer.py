# django_admin/apps/orders/serializers/order_serializer.py
# backend/django_admin/apps/orders/serializers/order_serializer.py
from rest_framework import serializers
from decimal import Decimal
from apps.products.models import Product
from apps.products.serializers import ProductSerializer
from ..models import Order, SubOrder, OrderItem

class CartItemSerializer(serializers.Serializer):
    """For adding to cart: product UUID and quantity."""
    product_uuid = serializers.UUIDField()
    quantity = serializers.DecimalField(max_digits=12, decimal_places=2, min_value=Decimal('0.01'))

class OrderItemSerializer(serializers.ModelSerializer):
    product_detail = ProductSerializer(source='product', read_only=True)

    class Meta:
        model = OrderItem
        fields = ('id', 'product', 'product_detail', 'quantity', 'unit_price', 'total_price')

class SubOrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    farmer_phone = serializers.CharField(source='farmer.user.phone', read_only=True)

    class Meta:
        model = SubOrder
        fields = ('id', 'farmer', 'farmer_phone', 'status', 'subtotal', 'items', 'confirmed_at', 'ready_at')

class OrderSerializer(serializers.ModelSerializer):
    sub_orders = SubOrderSerializer(many=True, read_only=True)
    buyer_phone = serializers.CharField(source='buyer.phone', read_only=True)

    class Meta:
        model = Order
        fields = (
            'id', 'uuid', 'buyer', 'buyer_phone', 'total_amount', 'delivery_fee',
            'platform_commission', 'status', 'account_number', 'delivery_address',
            'scheduled_date', 'scheduled_time_window', 'assigned_provider',
            'sub_orders', 'created_at', 'paid_at', 'delivered_at'
        )
        read_only_fields = ('id', 'uuid', 'account_number', 'status', 'created_at', 'paid_at', 'delivered_at')

class OrderCreateSerializer(serializers.Serializer):
    """Create order from cart items."""
    delivery_address = serializers.CharField()
    scheduled_date = serializers.DateField()
    scheduled_time_window = serializers.CharField(max_length=50)
    items = CartItemSerializer(many=True)

    def validate(self, attrs):
        # Ensure all products exist and are active
        product_uuids = [item['product_uuid'] for item in attrs['items']]
        products = Product.objects.filter(uuid__in=product_uuids, is_active=True)
        if len(products) != len(product_uuids):
            raise serializers.ValidationError("One or more products are invalid or inactive.")
        # Group by farmer
        farmer_map = {}
        for product in products:
            farmer_map[product.farmer_id] = farmer_map.get(product.farmer_id, []) + [product]
        attrs['grouped_products'] = farmer_map
        return attrs