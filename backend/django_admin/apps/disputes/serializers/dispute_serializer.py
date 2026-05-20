# backend/django_admin/apps/disputes/serializers/dispute_serializer.py
from rest_framework import serializers
from ..models import Dispute
from apps.orders.serializers import OrderSerializer

class DisputeSerializer(serializers.ModelSerializer):
    raised_by_phone = serializers.CharField(source='raised_by.phone', read_only=True)
    order_detail = OrderSerializer(source='order', read_only=True)

    class Meta:
        model = Dispute
        fields = (
            'id', 'uuid', 'order', 'order_detail', 'raised_by', 'raised_by_phone',
            'reason', 'description', 'evidence_photos', 'status', 'resolution_type',
            'resolution_notes', 'resolved_by', 'resolved_at', 'refund_amount',
            'penalty_amount', 'penalty_user', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at', 'status', 'resolved_at')

class DisputeCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dispute
        fields = ('order', 'reason', 'description', 'evidence_photos')

    def validate_order(self, value):
        # Allow only if the user is the buyer or farmer or provider related to the order
        user = self.context['request'].user
        if user.role == 'buyer' and value.buyer != user:
            raise serializers.ValidationError("You can only dispute your own orders.")
        if user.role == 'farmer' and value.farmer_profile.user != user:
            raise serializers.ValidationError("You can only dispute orders for your products.")
        if user.role == 'transport_provider' and hasattr(value, 'trip') and value.trip.provider.user != user:
            raise serializers.ValidationError("You can only dispute orders you delivered.")
        return value

class DisputeResolutionSerializer(serializers.Serializer):
    """Admin-only: resolve a dispute."""
    resolution_type = serializers.ChoiceField(choices=Dispute.RESOLUTION_TYPES)
    refund_amount = serializers.DecimalField(max_digits=10, decimal_places=2, required=False, default=0)
    penalty_amount = serializers.DecimalField(max_digits=10, decimal_places=2, required=False, default=0)
    penalty_user_id = serializers.IntegerField(required=False, allow_null=True)
    resolution_notes = serializers.CharField(required=False, allow_blank=True)