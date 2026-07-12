from rest_framework import serializers
from ..models import NotificationPreference


class NotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationPreference
        fields = ('id', 'uuid', 'user', 'channel', 'category', 'enabled', 'quiet_hours_start', 'quiet_hours_end', 'created_at', 'updated_at')
        read_only_fields = ('id', 'uuid', 'user', 'created_at', 'updated_at')
