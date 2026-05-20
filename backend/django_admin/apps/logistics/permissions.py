# backend/django_admin/apps/logistics/permissions.py
from rest_framework import permissions

class IsAssignedProvider(permissions.BasePermission):
    """Allow only the provider assigned to the trip."""
    def has_object_permission(self, request, view, obj):
        return request.user.is_authenticated and obj.provider and obj.provider.user == request.user

class IsOrderBuyer(permissions.BasePermission):
    """Allow only the buyer who placed the order."""
    def has_object_permission(self, request, view, obj):
        return request.user.is_authenticated and obj.order.buyer == request.user