# Callback serializer
# backend/django_admin/apps/paybill/serializers/callback_serializer.py
from rest_framework import serializers
from apps.paybill.models import PayBillTransaction
from core.validators import validate_phone_number

class IPNCallbackSerializer(serializers.Serializer):
    """
    Validates incoming Safaricom IPN payload.
    """
    TransactionCode = serializers.CharField(max_length=50, required=True)
    Amount = serializers.DecimalField(max_digits=10, decimal_places=2, required=True)
    AccountNumber = serializers.CharField(max_length=50, required=True)
    PhoneNumber = serializers.CharField(max_length=15, required=True)
    Time = serializers.RegexField(regex=r'^\d{14}$', required=True)
    BillRefNumber = serializers.CharField(max_length=50, required=False, allow_blank=True)

    def validate_PhoneNumber(self, value):
        validate_phone_number(value)
        return value

class PayBillTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = PayBillTransaction
        fields = [
            'id', 'uuid', 'transaction_code', 'amount', 'account_number',
            'sender_phone', 'transaction_time', 'status', 'matched_order_id',
            'notes', 'created_at'
        ]
        read_only_fields = ['id', 'uuid', 'created_at']