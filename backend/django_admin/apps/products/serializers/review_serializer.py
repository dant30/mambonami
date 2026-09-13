from rest_framework import serializers

from apps.orders.models import OrderItem
from ..models import ProductReview


class ProductReviewSerializer(serializers.ModelSerializer):
    buyer_name = serializers.CharField(source='buyer.display_name', read_only=True)
    order_item = serializers.PrimaryKeyRelatedField(queryset=OrderItem.objects.all(), write_only=True)

    class Meta:
        model = ProductReview
        fields = ('id', 'uuid', 'product', 'buyer_name', 'order_item', 'rating', 'comment', 'created_at')
        read_only_fields = ('id', 'uuid', 'product', 'buyer_name', 'created_at')

    def validate_order_item(self, order_item):
        request = self.context['request']
        if order_item.sub_order.order.buyer_id != request.user.id:
            raise serializers.ValidationError('You can only review products from your own orders.')
        if order_item.sub_order.order.status != 'delivered':
            raise serializers.ValidationError('Reviews are available after delivery.')
        if ProductReview.objects.filter(order_item=order_item).exists():
            raise serializers.ValidationError('This order item has already been reviewed.')
        return order_item

    def validate(self, attrs):
        product = self.context['product']
        if attrs['order_item'].product_id != product.id:
            raise serializers.ValidationError({'order_item': 'The order item does not match this product.'})
        return attrs

    def create(self, validated_data):
        return ProductReview.objects.create(product=self.context['product'], buyer=self.context['request'].user, **validated_data)
