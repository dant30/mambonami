# backend/django_admin/apps/disputes/permissions.py
from rest_framework import permissions

class CanResolveDispute(permissions.BasePermission):
    """Only admins can resolve disputes."""
    def has_permission(self, request, view):
        return request.user.is_staff

class CanViewDispute(permissions.BasePermission):
    """User can view if they are admin or involved in the order."""
    def has_object_permission(self, request, view, obj):
        if request.user.is_staff:
            return True
        user = request.user
        return (obj.raised_by == user or
                obj.order.buyer == user or
                obj.order.farmer_profile.user == user or
                (hasattr(obj.order, 'trip') and obj.order.trip.provider.user == user))