# backend/django_admin/apps/analytics/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views.api import DailyMetricViewSet

router = DefaultRouter()
router.register(r'metrics', DailyMetricViewSet, basename='metric')

urlpatterns = [
    path('', include(router.urls)),
]
