# backend/django_admin/apps/notifications/serializers/notification_serializer.py
from rest_framework import serializers
from django.utils.timesince import timesince
from ..models import Notification

class NotificationSerializer(serializers.ModelSerializer):
    is_unread = serializers.SerializerMethodField()
    time_ago = serializers.SerializerMethodField()
    type = serializers.CharField(source='notification_type', read_only=True)

    class Meta:
        model = Notification
        fields = (
            'id', 'uuid', 'channel', 'title', 'body', 'metadata',
            'status', 'notification_type', 'type', 'is_unread', 'time_ago',
            'created_at', 'read_at'
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'read_at', 'type')

    def get_is_unread(self, obj):
        return obj.status != 'read'

    def get_time_ago(self, obj):
        return timesince(obj.created_at)


class MarkReadSerializer(serializers.Serializer):
    notification_ids = serializers.ListField(child=serializers.IntegerField())