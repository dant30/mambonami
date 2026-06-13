from django.urls import path

from .views.api import AuditLogDetailView, AuditLogListView

urlpatterns = [
    path('logs/', AuditLogListView.as_view(), name='admin-audit-log-list'),
    path('logs/<uuid:uuid>/', AuditLogDetailView.as_view(), name='admin-audit-log-detail'),
]