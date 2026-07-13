# apps/paybill/serializers/settlement_serializer.py
from rest_framework import serializers
from apps.paybill.models import PayBillSettlement

class SettlementSerializer(serializers.ModelSerializer):
    class Meta:
        model = PayBillSettlement
        fields = '__all__'