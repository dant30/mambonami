# backend/django_admin/apps/notifications/serializers/notification_serializer.py
from rest_framework import serializers
from ..models import Notification

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = (
            'id', 'uuid', 'channel', 'title', 'body', 'metadata',
            'status', 'created_at', 'read_at'
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'read_at')

class MarkReadSerializer(serializers.Serializer):
    notification_ids = serializers.ListField(child=serializers.IntegerField())