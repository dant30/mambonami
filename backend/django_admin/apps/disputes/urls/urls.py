# backend/django_admin/apps/disputes/urls.py
from django.urls import path
from ..views import api

urlpatterns = [
    path('', api.DisputeListView.as_view(), name='dispute-list'),
    path('create/', api.DisputeCreateView.as_view(), name='dispute-create'),
    path('<uuid:uuid>/', api.DisputeDetailView.as_view(), name='dispute-detail'),
    path('<uuid:uuid>/resolve/', api.DisputeResolveView.as_view(), name='dispute-resolve'),
]