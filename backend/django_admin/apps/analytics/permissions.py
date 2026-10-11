# backend/django_admin/apps/analytics/permissions.py
from rest_framework import permissions
from apps.users.permissions import is_admin_user

class CanViewAnalytics(permissions.BasePermission):
    """Only admins can view analytics."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and is_admin_user(request.user)