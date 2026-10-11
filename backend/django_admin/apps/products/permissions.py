# backend/django_admin/apps/products/permissions.py
from rest_framework import permissions
from apps.users.permissions import is_admin_user

class IsProductOwner(permissions.BasePermission):
    """Object-level permission to allow only farmers who own the product."""
    def has_object_permission(self, request, view, obj):
        # Admin can do anything
        if is_admin_user(request.user):
            return True
        # Farmer can modify their own product
        return obj.farmer.user == request.user