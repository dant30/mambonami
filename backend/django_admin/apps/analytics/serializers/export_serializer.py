from rest_framework import serializers
from ..models import AnalyticsExportJob


class AnalyticsExportJobSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnalyticsExportJob
        fields = ('id', 'uuid', 'requested_by', 'export_format', 'filters', 'status', 'file_path', 'error_message', 'created_at', 'updated_at')
        read_only_fields = ('id', 'uuid', 'created_at', 'updated_at', 'file_path', 'status', 'error_message')
