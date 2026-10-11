# backend/django_admin/apps/orders/serializers/order_serializer.py
from rest_framework import serializers
from decimal import Decimal
from django.conf import settings
from django.utils.timesince import timesince
from apps.products.models import Product
from apps.products.serializers import ProductSerializer
from ..models import Order, SubOrder, OrderItem

class CartItemSerializer(serializers.Serializer):
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
    order_status = serializers.CharField(source='order.status', read_only=True)

    class Meta:
        model = SubOrder
        fields = ('id', 'farmer', 'farmer_phone', 'order_status', 'status', 'subtotal', 'farmer_payout', 'items', 'confirmed_at', 'ready_at', 'created_at')

class OrderSerializer(serializers.ModelSerializer):
    sub_orders = SubOrderSerializer(many=True, read_only=True)
    buyer_phone = serializers.CharField(source='buyer.phone', read_only=True)
    buyer_name = serializers.CharField(source='buyer.display_name', read_only=True)
    paybill_number = serializers.SerializerMethodField()
    stk_payment_status = serializers.SerializerMethodField()
    stk_payment_message = serializers.SerializerMethodField()
    time_ago = serializers.SerializerMethodField()
    item_summary = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = (
            'id', 'uuid', 'buyer', 'buyer_phone', 'buyer_name',
            'total_amount', 'delivery_fee', 'platform_commission',
            'promo_code', 'discount_amount',
            'status', 'account_number', 'delivery_address',
            'paybill_number', 'stk_payment_status', 'stk_payment_message',
            'delivery_street', 'delivery_city', 'delivery_postal_code', 'delivery_landmark',
            'delivery_lat', 'delivery_lng', 'total_weight_kg',
            'scheduled_date', 'scheduled_time_window', 'assigned_provider',
            'sub_orders', 'created_at', 'paid_at', 'delivered_at',
            'time_ago', 'item_summary',
        )
        read_only_fields = ('id', 'uuid', 'account_number', 'status', 'created_at', 'paid_at', 'delivered_at')

    def get_paybill_number(self, obj):
        return settings.MPESA_PAYBILL_NUMBER

    def _latest_stk_request(self, obj):
        return obj.stk_push_requests.order_by('-created_at').first()

    def get_stk_payment_status(self, obj):
        request = self._latest_stk_request(obj)
        return request.status if request else None

    def get_stk_payment_message(self, obj):
        request = self._latest_stk_request(obj)
        return request.result_description if request else ''

    def get_time_ago(self, obj):
        return timesince(obj.created_at)

    def get_item_summary(self, obj):
        items = []
        for sub in obj.sub_orders.all():
            for item in sub.items.all()[:2]:
                items.append(f"{item.product.name} {item.quantity}{item.product.unit}")
        return ", ".join(items[:3])

class OrderCreateSerializer(serializers.Serializer):
    delivery_address = serializers.CharField(required=False, allow_blank=True)
    delivery_street = serializers.CharField(required=False, allow_blank=True, max_length=200)
    delivery_city = serializers.CharField(required=False, allow_blank=True, max_length=100)
    delivery_postal_code = serializers.CharField(required=False, allow_blank=True, max_length=20)
    delivery_landmark = serializers.CharField(required=False, allow_blank=True, max_length=200)
    delivery_lat = serializers.DecimalField(max_digits=9, decimal_places=6)
    delivery_lng = serializers.DecimalField(max_digits=9, decimal_places=6)
    scheduled_date = serializers.DateField()
    scheduled_time_window = serializers.CharField(max_length=50)
    payment_method = serializers.CharField(required=False, allow_blank=True, allow_null=True, max_length=64)
    promo_code = serializers.CharField(required=False, allow_blank=True, max_length=30)
    items = CartItemSerializer(many=True)

    def validate_items(self, value):
        if not value:
            raise serializers.ValidationError('Add at least one item to the order.')
        return value

    def validate_delivery_lat(self, value):
        if value < Decimal('-12.0') or value > Decimal('5.0'):
            raise serializers.ValidationError("Delivery latitude is out of expected bounds.")
        return value

    def validate_delivery_lng(self, value):
        if value < Decimal('34.0') or value > Decimal('42.0'):
            raise serializers.ValidationError("Delivery longitude is out of expected bounds.")
        return value

    def validate(self, attrs):
        attrs['delivery_landmark'] = (attrs.get('delivery_landmark') or '').strip()
        product_uuids = [item['product_uuid'] for item in attrs['items']]
        products = Product.objects.filter(uuid__in=product_uuids, is_active=True)
        if len(products) != len(product_uuids):
            raise serializers.ValidationError("One or more products are invalid or inactive.")
        
        product_lookup = {p.uuid: p for p in products}
        farmer_map = {}
        for item in attrs['items']:
            prod = product_lookup.get(item['product_uuid'])
            if not prod:
                raise serializers.ValidationError("One or more products are invalid or inactive.")
            farmer_products = farmer_map.get(prod.farmer_id, [])
            farmer_products.append({'product': prod, 'quantity': item['quantity']})
            farmer_map[prod.farmer_id] = farmer_products
        attrs['grouped_products'] = farmer_map

        if not attrs.get('delivery_address'):
            street = attrs.get('delivery_street', '').strip()
            city = attrs.get('delivery_city', '').strip()
            postal_code = attrs.get('delivery_postal_code', '').strip()
            landmark = attrs['delivery_landmark']
            if street or city or postal_code or landmark:
                address_parts = [part for part in [street, city, postal_code, landmark] if part]
                attrs['delivery_address'] = ', '.join(address_parts)
            else:
                raise serializers.ValidationError({
                    'delivery_address': 'Either delivery_address or structured delivery fields are required.'
                })

        # Validate promo code if provided
        if attrs.get('promo_code'):
            from apps.orders.models.promo import PromoCode
            try:
                promo = PromoCode.objects.get(code=attrs['promo_code'], is_active=True)
                # Check validity
                from django.utils import timezone
                if promo.valid_from > timezone.now() or promo.valid_until < timezone.now():
                    raise serializers.ValidationError({'promo_code': 'Promo code expired.'})
                if promo.times_used >= promo.max_uses:
                    raise serializers.ValidationError({'promo_code': 'Promo code already used.'})
                attrs['_promo_code'] = promo
            except PromoCode.DoesNotExist:
                raise serializers.ValidationError({'promo_code': 'Invalid promo code.'})

        return attrs