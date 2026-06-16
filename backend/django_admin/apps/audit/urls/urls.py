# backend/django_admin/apps/audit/urls.py
from django.urls import path
from ..views import api

urlpatterns = [
    path('', api.AuditLogListView.as_view(), name='audit-list'),
    path('<uuid:uuid>/', api.AuditLogDetailView.as_view(), name='audit-detail'),
]