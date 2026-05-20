# backend/django_admin/apps/audit/permissions.py
# backend/django_admin/apps/audit/permissions.py
from rest_framework import permissions

class CanViewAuditLogs(permissions.BasePermission):
    """Only superusers and staff with specific permission can view audit logs."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and (
            request.user.is_superuser or
            request.user.has_perm('audit.view_auditlog')
        )