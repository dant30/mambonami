# Callback serializer
# backend/django_admin/apps/paybill/serializers/callback_serializer.py
from rest_framework import serializers
from apps.paybill.models import PayBillTransaction
from core.validators import validate_phone_number


class IPNCallbackSerializer(serializers.Serializer):
    """
    Validates incoming Safaricom IPN payload.
    Additional optional fields are captured in the handler.
    """
    TransactionCode = serializers.CharField(max_length=50, required=True)
    Amount = serializers.DecimalField(max_digits=10, decimal_places=2, required=True)
    AccountNumber = serializers.CharField(max_length=50, required=True)
    PhoneNumber = serializers.CharField(max_length=15, required=True)
    Time = serializers.RegexField(regex=r'^\d{14}$', required=True)
    BillRefNumber = serializers.CharField(max_length=50, required=False, allow_blank=True)
    FirstName = serializers.CharField(max_length=50, required=False, allow_blank=True)
    MiddleName = serializers.CharField(max_length=50, required=False, allow_blank=True)
    LastName = serializers.CharField(max_length=50, required=False, allow_blank=True)
    BusinessShortCode = serializers.CharField(max_length=10, required=False, allow_blank=True)
    TransactionType = serializers.CharField(max_length=20, required=False, allow_blank=True)

    def validate_PhoneNumber(self, value):
        validate_phone_number(value)
        return value


class PayBillSimulationSerializer(serializers.Serializer):
    TransactionCode = serializers.CharField(max_length=50, required=True)
    Amount = serializers.DecimalField(max_digits=10, decimal_places=2, required=True)
    AccountNumber = serializers.CharField(max_length=50, required=True)
    PhoneNumber = serializers.CharField(max_length=15, required=True)
    Time = serializers.RegexField(regex=r'^\d{14}$', required=True)
    BillRefNumber = serializers.CharField(max_length=50, required=False, allow_blank=True)
    FirstName = serializers.CharField(max_length=50, required=False, allow_blank=True)
    MiddleName = serializers.CharField(max_length=50, required=False, allow_blank=True)
    LastName = serializers.CharField(max_length=50, required=False, allow_blank=True)
    BusinessShortCode = serializers.CharField(max_length=10, required=False, allow_blank=True)
    TransactionType = serializers.CharField(max_length=20, required=False, allow_blank=True)


class PayBillTransactionSerializer(serializers.ModelSerializer):
    matched_order_id = serializers.IntegerField(source='matched_order.id', read_only=True)
    order_uuid = serializers.UUIDField(source='matched_order.uuid', read_only=True)

    class Meta:
        model = PayBillTransaction
        fields = [
            'id', 'uuid', 'transaction_code', 'amount', 'account_number',
            'sender_phone', 'payer_first_name', 'payer_middle_name', 'payer_last_name',
            'business_shortcode', 'transaction_type', 'currency',
            'transaction_time', 'status', 'matched_order_id', 'order_uuid',
            'running_balance', 'notes', 'created_at'
        ]
        read_only_fields = ['id', 'uuid', 'created_at']