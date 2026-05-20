# backend/django_admin/apps/payouts/serializers/payout_serializer.py
from rest_framework import serializers
from ..models import Payout

class PayoutSerializer(serializers.ModelSerializer):
    recipient_phone = serializers.CharField(source='recipient_user.phone', read_only=True)
    order_uuid = serializers.CharField(source='order.uuid', read_only=True)

    class Meta:
        model = Payout
        fields = (
            'id', 'uuid', 'order', 'order_uuid', 'recipient_type', 'recipient_user',
            'recipient_phone', 'amount', 'b2c_transaction_id', 'status',
            'error_message', 'retry_count', 'paid_at', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at', 'b2c_transaction_id', 'paid_at')