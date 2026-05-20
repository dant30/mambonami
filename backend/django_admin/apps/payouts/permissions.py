# backend/django_admin/apps/payouts/permissions.py
from rest_framework import permissions

class CanViewPayouts(permissions.BasePermission):
    """Allow admin or the recipient user to view their own payouts."""
    def has_permission(self, request, view):
        if request.user.is_staff:
            return True
        # For non-admin, we'll do object-level check in has_object_permission
        return request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        return request.user.is_staff or obj.recipient_user == request.user