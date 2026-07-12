# backend/django_admin/apps/notifications/serializers/notification_serializer.py
from rest_framework import serializers
from django.utils.timesince import timesince
from ..models import Notification, NotificationPreference


class NotificationSerializer(serializers.ModelSerializer):
    is_unread = serializers.SerializerMethodField()
    time_ago = serializers.SerializerMethodField()
    type = serializers.CharField(source='notification_type', read_only=True)
    status = serializers.CharField(source='delivery_status', read_only=True)

    class Meta:
        model = Notification
        fields = (
            'id', 'uuid', 'channel', 'category', 'priority', 'title', 'body', 'metadata',
            'status', 'delivery_status', 'notification_type', 'type', 'is_unread', 'time_ago',
            'is_read', 'action_url', 'image', 'external_id', 'error_message', 'delivered_at', 'read_at',
            'expires_at', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at', 'read_at', 'type', 'status')

    def get_is_unread(self, obj):
        return not obj.is_read

    def get_time_ago(self, obj):
        return timesince(obj.created_at)


class NotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationPreference
        fields = (
            'id', 'uuid', 'user', 'channel', 'category', 'enabled',
            'quiet_hours_start', 'quiet_hours_end', 'language', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'uuid', 'user', 'created_at', 'updated_at')


class MarkReadSerializer(serializers.Serializer):
    notification_ids = serializers.ListField(child=serializers.IntegerField())
