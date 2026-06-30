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
        fields = ('id', 'farmer', 'farmer_phone', 'status', 'subtotal', 'farmer_payout', 'items', 'confirmed_at', 'ready_at')

class OrderSerializer(serializers.ModelSerializer):
    sub_orders = SubOrderSerializer(many=True, read_only=True)
    buyer_phone = serializers.CharField(source='buyer.phone', read_only=True)

    class Meta:
        model = Order
        fields = (
            'id', 'uuid', 'buyer', 'buyer_phone', 'total_amount', 'delivery_fee',
            'platform_commission', 'status', 'account_number', 'delivery_address',
            'delivery_street', 'delivery_city', 'delivery_postal_code', 'delivery_landmark',
            'delivery_lat', 'delivery_lng', 'total_weight_kg',
            'scheduled_date', 'scheduled_time_window', 'assigned_provider',
            'sub_orders', 'created_at', 'paid_at', 'delivered_at'
        )
        read_only_fields = ('id', 'uuid', 'account_number', 'status', 'created_at', 'paid_at', 'delivered_at')

class OrderCreateSerializer(serializers.Serializer):
    """Create order from cart items with delivery location."""
    delivery_address = serializers.CharField(required=False, allow_blank=True)
    delivery_street = serializers.CharField(required=False, allow_blank=True, max_length=200)
    delivery_city = serializers.CharField(required=False, allow_blank=True, max_length=100)
    delivery_postal_code = serializers.CharField(required=False, allow_blank=True, max_length=20)
    delivery_landmark = serializers.CharField(required=False, allow_blank=True, max_length=200)
    delivery_lat = serializers.DecimalField(max_digits=9, decimal_places=6, help_text="Latitude of delivery location")
    delivery_lng = serializers.DecimalField(max_digits=9, decimal_places=6, help_text="Longitude of delivery location")
    scheduled_date = serializers.DateField()
    scheduled_time_window = serializers.CharField(max_length=50)
    payment_method = serializers.CharField(required=False, allow_blank=True, max_length=64)
    items = CartItemSerializer(many=True)

    def validate_delivery_lat(self, value):
        if value < Decimal('-12.0') or value > Decimal('5.0'):
            raise serializers.ValidationError("Delivery latitude is out of expected bounds.")
        return value

    def validate_delivery_lng(self, value):
        if value < Decimal('34.0') or value > Decimal('42.0'):
            raise serializers.ValidationError("Delivery longitude is out of expected bounds.")
        return value

    def validate(self, attrs):
        # Ensure all products exist and are active
        product_uuids = [item['product_uuid'] for item in attrs['items']]
        products = Product.objects.filter(uuid__in=product_uuids, is_active=True)
        if len(products) != len(product_uuids):
            raise serializers.ValidationError("One or more products are invalid or inactive.")
        # Build lookup of products by UUID for merging quantities
        product_lookup = {p.uuid: p for p in products}
        # Group by farmer, preserving quantity per item
        farmer_map = {}
        for item in attrs['items']:
            prod = product_lookup.get(item['product_uuid'])
            if not prod:
                raise serializers.ValidationError("One or more products are invalid or inactive.")
            farmer_products = farmer_map.get(prod.farmer_id, [])
            farmer_products.append({'product': prod, 'quantity': item['quantity']})
            farmer_map[prod.farmer_id] = farmer_products
        attrs['grouped_products'] = farmer_map

        # Structured address support
        if not attrs.get('delivery_address'):
            street = attrs.get('delivery_street', '').strip()
            city = attrs.get('delivery_city', '').strip()
            postal_code = attrs.get('delivery_postal_code', '').strip()
            landmark = attrs.get('delivery_landmark', '').strip()

            if street or city or postal_code or landmark:
                address_parts = [part for part in [street, city, postal_code, landmark] if part]
                attrs['delivery_address'] = ', '.join(address_parts)
            else:
                raise serializers.ValidationError({
                    'delivery_address': 'Either delivery_address or structured delivery fields are required.'
                })

        return attrs