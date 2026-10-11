# backend/django_admin/apps/payments/permissions.py
from rest_framework import permissions
from apps.users.permissions import is_admin_user

class CanProcessPayment(permissions.BasePermission):
    """Placeholder for future payment processing permission."""
    def has_permission(self, request, view):
        return is_admin_user(request.user)