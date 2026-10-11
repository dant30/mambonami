# backend/django_admin/apps/orders/permissions.py
from rest_framework import permissions
from apps.users.permissions import is_admin_user

class IsBuyer(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ['buyer', 'retailer']

class IsFarmerForSubOrder(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        # obj is SubOrder
        return obj.farmer.user == request.user or is_admin_user(request.user)

class IsTransportProviderForOrder(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        # obj is Order
        return obj.assigned_provider and obj.assigned_provider.user == request.user