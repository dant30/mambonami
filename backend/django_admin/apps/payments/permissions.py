# backend/django_admin/apps/payments/permissions.py
from rest_framework import permissions

class CanProcessPayment(permissions.BasePermission):
    """Placeholder for future payment processing permission."""
    def has_permission(self, request, view):
        return request.user.is_staff