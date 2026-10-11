# backend/django_admin/apps/audit/serializers/audit_serializer.py
# backend/django_admin/apps/audit/serializers/audit_serializer.py
from rest_framework import serializers
from ..models import AuditLog


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