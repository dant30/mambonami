# backend/django_admin/apps/payouts/permissions.py
from rest_framework import permissions
from apps.users.permissions import is_admin_user

class CanViewPayouts(permissions.BasePermission):
    """Allow admin or the recipient user to view their own payouts."""
    def has_permission(self, request, view):
        if is_admin_user(request.user):
            return True
        # For non-admin, we'll do object-level check in has_object_permission
        return request.user.is_authenticated

    def has_object_permission(self, request, view, obj):
        return is_admin_user(request.user) or obj.recipient_user == request.user