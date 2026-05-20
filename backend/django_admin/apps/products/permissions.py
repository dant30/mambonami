# backend/django_admin/apps/products/permissions.py
from rest_framework import permissions

class IsProductOwner(permissions.BasePermission):
    """Object-level permission to allow only farmers who own the product."""
    def has_object_permission(self, request, view, obj):
        # Admin can do anything
        if request.user.is_staff:
            return True
        # Farmer can modify their own product
        return obj.farmer.user == request.user