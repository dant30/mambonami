# backend/django_admin/apps/disputes/permissions.py
from rest_framework import permissions
from apps.users.permissions import is_admin_user

class CanResolveDispute(permissions.BasePermission):
    """Only admins can resolve disputes."""
    def has_permission(self, request, view):
        return is_admin_user(request.user)

class CanViewDispute(permissions.BasePermission):
    """User can view if they are admin or involved in the order."""
    def has_object_permission(self, request, view, obj):
        if is_admin_user(request.user):
            return True
        user = request.user
        return (obj.raised_by == user or
                obj.order.buyer == user or
                obj.order.farmer_profile.user == user or
                (hasattr(obj.order, 'trip') and obj.order.trip.provider.user == user))