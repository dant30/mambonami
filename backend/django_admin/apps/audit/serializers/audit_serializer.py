# backend/django_admin/apps/audit/serializers/audit_serializer.py
# backend/django_admin/apps/audit/serializers/audit_serializer.py
from rest_framework import serializers
from ..models import AuditLog
from apps.users.serializers import UserDetailSerializer

class AuditLogSerializer(serializers.ModelSerializer):
    user_detail = UserDetailSerializer(source='user', read_only=True)

    class Meta:
        model = AuditLog
        fields = (
            'id', 'uuid', 'user', 'user_detail', 'user_ip', 'user_agent',
            'action', 'model_name', 'object_id', 'object_repr', 'changes',
            'timestamp', 'request_id', 'endpoint'
        )
        read_only_fields = '__all__'