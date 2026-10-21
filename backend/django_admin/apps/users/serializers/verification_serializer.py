from rest_framework import serializers
from ..models import VerificationDocument, TrustScore, User
from ..permissions import is_admin_user

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

    def get_fields(self):
        fields = super().get_fields()
        request = self.context.get('request')
        user = getattr(request, 'user', None)
        if user and not is_admin_user(user):
            fields['status'].read_only = True
            fields['notes'].read_only = True
        return fields

    def validate_document_type(self, value):
        request = self.context.get('request')
        user = getattr(request, 'user', None)
        if not user or is_admin_user(user):
            return value
        allowed_by_role = {
            'buyer': {'national_id'},
            'farmer': {'national_id', 'coop_certificate'},
            'retailer': {'national_id', 'business_license'},
            'transport_provider': {'national_id', 'driver_license'},
        }
        if value not in allowed_by_role.get(user.role, set()):
            raise serializers.ValidationError('This document type is not available for your account role.')
        return value


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