# core/permissions.py
from rest_framework import permissions

class IsFarmer(permissions.BasePermission):
    """Allow access only to users with role 'farmer'."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'farmer'

class IsTransportProvider(permissions.BasePermission):
    """Allow access only to transport providers."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'transport_provider'

class IsBuyer(permissions.BasePermission):
    """Allow access only to buyers (consumers or retailers)."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ['consumer', 'retailer']

class IsAdmin(permissions.BasePermission):
    """Allow access only to admin users."""
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.is_staff

class IsOwnerOrAdmin(permissions.BasePermission):
    """Object-level permission: user can modify only their own objects, admins can do anything."""
    def has_object_permission(self, request, view, obj):
        if request.user.is_staff:
            return True
        # Assume obj has a 'user' attribute pointing to the owner
        return hasattr(obj, 'user') and obj.user == request.user