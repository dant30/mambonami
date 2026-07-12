from rest_framework import serializers
from ..models import VerificationDocument, TrustScore, User

class VerificationDocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = VerificationDocument
        fields = (
            'id', 'uuid', 'user', 'document_type', 'document_number',
            'file', 'mime_type', 'status', 'notes', 'expiry_date',
            'reviewed_by', 'verified_by', 'reviewed_at',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at', 'reviewed_by', 'reviewed_at', 'verified_by')


class TrustScoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrustScore
        fields = (
            'id', 'uuid', 'user', 'score', 'score_band', 'reason',
            'orders_completed', 'late_deliveries', 'disputes',
            'cancelled_orders', 'verification_level', 'payment_history',
            'last_calculated', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at', 'last_calculated')


class VerificationReviewSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=VerificationDocument.STATUS_CHOICES)
    notes = serializers.CharField(required=False, allow_blank=True)