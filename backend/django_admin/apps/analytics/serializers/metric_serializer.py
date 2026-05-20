# backend/django_admin/apps/analytics/serializers/metric_serializer.py
from rest_framework import serializers
from ..models import DailyMetric

class DailyMetricSerializer(serializers.ModelSerializer):
    class Meta:
        model = DailyMetric
        fields = '__all__'
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at')