# backend/django_admin/apps/audit/serializers/audit_serializer.py
# backend/django_admin/apps/audit/serializers/audit_serializer.py
from rest_framework import serializers
from ..models import AuditLog, SecurityEvent


class AuditActorSerializer(serializers.Serializer):
    id = serializers.IntegerField(read_only=True)
    phone = serializers.CharField(read_only=True)
    display_name = serializers.CharField(read_only=True)

class AuditLogSerializer(serializers.ModelSerializer):
    user_detail = AuditActorSerializer(source='user', read_only=True)
    actor = serializers.IntegerField(source='user_id', read_only=True, allow_null=True)
    actor_phone = serializers.CharField(source='user.phone', read_only=True, allow_null=True)
    resource_type = serializers.CharField(source='model_name', read_only=True)
    resource_id = serializers.CharField(source='object_id', read_only=True)
    description = serializers.CharField(source='object_repr', read_only=True)
    metadata = serializers.JSONField(source='changes', read_only=True)
    created_at = serializers.DateTimeField(source='timestamp', read_only=True)

    class Meta:
        model = AuditLog
        fields = (
            'id', 'uuid', 'user', 'user_detail', 'user_ip', 'user_agent',
            'action', 'model_name', 'object_id', 'object_repr', 'changes',
            'timestamp', 'request_id', 'endpoint', 'actor', 'actor_phone',
            'resource_type', 'resource_id', 'description', 'metadata', 'created_at',
        )
        read_only_fields = (
            'id', 'uuid', 'user', 'user_detail', 'user_ip', 'user_agent',
            'action', 'model_name', 'object_id', 'object_repr', 'changes',
            'timestamp', 'request_id', 'endpoint', 'actor', 'actor_phone',
            'resource_type', 'resource_id', 'description', 'metadata', 'created_at',
        )


class SecurityEventSerializer(serializers.ModelSerializer):
    actor_phone = serializers.CharField(source='user.phone', read_only=True, allow_null=True)

    class Meta:
        model = SecurityEvent
        fields = (
            'id', 'uuid', 'event_type', 'description', 'severity', 'user', 'actor_phone',
            'ip_address', 'request_id', 'investigated', 'investigation_notes',
            'resolved_at', 'created_at',
        )
        read_only_fields = (
            'id', 'uuid', 'event_type', 'description', 'severity', 'user',
            'actor_phone', 'ip_address', 'request_id', 'created_at',
        )

    def validate(self, attrs):
        investigated = attrs.get('investigated', self.instance.investigated if self.instance else False)
        resolved_at = attrs.get('resolved_at', self.instance.resolved_at if self.instance else None)
        if resolved_at and not investigated:
            raise serializers.ValidationError({'investigated': 'Resolve an event only after marking it investigated.'})
        return attrs