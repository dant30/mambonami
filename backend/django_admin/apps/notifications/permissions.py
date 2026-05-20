# backend/django_admin/apps/notifications/permissions.py
from rest_framework import permissions

class IsOwner(permissions.BasePermission):
    """User can only access their own notifications."""
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user