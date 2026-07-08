# backend/django_admin/apps/notifications/serializers/notification_serializer.py
from rest_framework import serializers
from django.utils.timesince import timesince
from ..models import Notification

class NotificationSerializer(serializers.ModelSerializer):
    isUnread = serializers.SerializerMethodField()
    timeAgo = serializers.SerializerMethodField()
    
    class Meta:
        model = Notification
        fields = (
            'id', 'uuid', 'channel', 'title', 'body', 'type', 'metadata',
            'status', 'isUnread', 'timeAgo', 'created_at', 'read_at'
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'read_at', 'type')
    
    def get_isUnread(self, obj):
        """Return True if notification hasn't been read."""
        return obj.read_at is None
    
    def get_timeAgo(self, obj):
        """Return relative time string (e.g., '5 minutes ago')."""
        return timesince(obj.created_at) + ' ago'

class MarkReadSerializer(serializers.Serializer):
    notification_ids = serializers.ListField(child=serializers.IntegerField())