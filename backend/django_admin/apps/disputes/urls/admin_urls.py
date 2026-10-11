from django.urls import path

app_name = 'admin_disputes'

from ..views.api import DisputeDetailView, DisputeListView, DisputeResolveView
from ..views.admin_views import DisputeStartReviewView

urlpatterns = [
    path('', DisputeListView.as_view(), name='admin-dispute-list'),
    path('<uuid:uuid>/', DisputeDetailView.as_view(), name='admin-dispute-detail'),
    path('<uuid:uuid>/review/', DisputeStartReviewView.as_view(), name='admin-dispute-start-review'),
    path('<uuid:uuid>/resolve/', DisputeResolveView.as_view(), name='admin-dispute-resolve'),
]