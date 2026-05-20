# backend/django_admin/apps/analytics/permissions.py
from rest_framework import permissions

class CanViewAnalytics(permissions.BasePermission):
    """Only admins can view analytics."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.is_staff