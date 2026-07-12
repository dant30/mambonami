from rest_framework import serializers
from ..models import VerificationDocument, TrustScore, User


class VerificationDocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = VerificationDocument
        fields = ('id', 'uuid', 'user', 'document_type', 'file', 'status', 'notes', 'reviewed_by', 'reviewed_at', 'created_at', 'updated_at')
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at', 'reviewed_by', 'reviewed_at')


class TrustScoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrustScore
        fields = ('id', 'uuid', 'user', 'score', 'score_band', 'reason', 'last_updated_at', 'created_at', 'updated_at')
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at', 'last_updated_at')


class VerificationReviewSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=VerificationDocument.STATUS_CHOICES)
    notes = serializers.CharField(required=False, allow_blank=True)
