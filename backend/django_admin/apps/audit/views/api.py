# backend/django_admin/apps/audit/views/api.py
# backend/django_admin/apps/audit/views/api.py
from rest_framework import generics, permissions, filters
from django_filters.rest_framework import DjangoFilterBackend
from ..models import AuditLog
from ..serializers import AuditLogSerializer
from apps.users.permissions import IsAdmin

class AuditLogListView(generics.ListAPIView):
    """Admin-only: list audit logs with filtering."""
    permission_classes = [IsAdmin]
    serializer_class = AuditLogSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter, filters.SearchFilter]
    filterset_fields = ['action', 'model_name', 'user']
    search_fields = ['object_id', 'object_repr']
    ordering_fields = ['timestamp', 'user']
    ordering = ['-timestamp']

    def get_queryset(self):
        queryset = AuditLog.objects.select_related('user')
        return queryset

class AuditLogDetailView(generics.RetrieveAPIView):
    """Admin-only: view a single audit log entry."""
    permission_classes = [IsAdmin]
    serializer_class = AuditLogSerializer
    queryset = AuditLog.objects.all()
    lookup_field = 'uuid'