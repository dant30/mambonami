# backend/django_admin/apps/analytics/urls.py
from django.urls import include, path
from rest_framework.routers import DefaultRouter

from ..views.api import (
    AnalyticsExportJobDetailView,
    AnalyticsExportJobListCreateView,
    DailyMetricViewSet,
)

router = DefaultRouter()

router.register(
    r"metrics",
    DailyMetricViewSet,
    basename="metric",
)

urlpatterns = [
    path("", include(router.urls)),
    path("exports/", AnalyticsExportJobListCreateView.as_view(), name="analytics-export-list"),
    path("exports/<uuid:uuid>/", AnalyticsExportJobDetailView.as_view(), name="analytics-export-detail"),
]