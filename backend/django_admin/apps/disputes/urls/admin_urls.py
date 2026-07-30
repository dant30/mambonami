from django.urls import path

app_name = 'admin_disputes'

from ..views.api import DisputeDetailView, DisputeListView, DisputeResolveView

urlpatterns = [
    path('', DisputeListView.as_view(), name='admin-dispute-list'),
    path('<uuid:uuid>/', DisputeDetailView.as_view(), name='admin-dispute-detail'),
    path('<uuid:uuid>/resolve/', DisputeResolveView.as_view(), name='admin-dispute-resolve'),
]