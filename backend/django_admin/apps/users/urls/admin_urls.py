# backend/django_admin/apps/users/urls/admin_urls.py
from django.urls import include, path
from rest_framework.routers import DefaultRouter

app_name = 'admin_users'

from ..views.admin_views import (
    FarmerAdminViewSet,
    StaffAdminViewSet,
    TransportProviderAdminViewSet,
    UserAdminViewSet,
)

router = DefaultRouter()
router.register('farmers', FarmerAdminViewSet, basename='admin-farmers')
router.register('transport-providers', TransportProviderAdminViewSet, basename='admin-transport-providers')
router.register('users', UserAdminViewSet, basename='admin-users')
router.register('staff', StaffAdminViewSet, basename='admin-staff')

urlpatterns = [
    path('', include(router.urls)),
]