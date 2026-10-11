# backend/django_admin/apps/audit/views/api.py
# backend/django_admin/apps/audit/views/api.py
from rest_framework import generics, permissions, filters
from django_filters.rest_framework import DjangoFilterBackend
from ..models import AuditLog, SecurityEvent
from ..serializers import AuditLogSerializer, SecurityEventSerializer
from apps.users.permissions import IsAdmin
from apps.audit.services import log_action

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


class SecurityEventListView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    serializer_class = SecurityEventSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter, filters.SearchFilter]
    filterset_fields = ['event_type', 'severity', 'investigated']
    search_fields = ['event_type', 'description', 'user__phone', 'ip_address', 'request_id']
    ordering_fields = ['created_at', 'severity', 'investigated']
    ordering = ['investigated', '-created_at']

    def get_queryset(self):
        return SecurityEvent.objects.select_related('user')


class SecurityEventDetailView(generics.RetrieveUpdateAPIView):
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    serializer_class = SecurityEventSerializer
    queryset = SecurityEvent.objects.select_related('user')
    lookup_field = 'uuid'
    http_method_names = ['get', 'patch', 'head', 'options']

    def perform_update(self, serializer):
        event = serializer.instance
        before = {
            'investigated': event.investigated,
            'investigation_notes': event.investigation_notes,
            'resolved_at': event.resolved_at.isoformat() if event.resolved_at else None,
        }
        updated_event = serializer.save()
        after = {
            'investigated': updated_event.investigated,
            'investigation_notes': updated_event.investigation_notes,
            'resolved_at': updated_event.resolved_at.isoformat() if updated_event.resolved_at else None,
        }
        changes = {key: [before[key], after[key]] for key in before if before[key] != after[key]}
        if changes:
            log_action(
                user=self.request.user,
                action='UPDATE',
                model_name='audit.SecurityEvent',
                object_id=updated_event.pk,
                object_repr=str(updated_event),
                changes=changes,
                request=self.request,
            )