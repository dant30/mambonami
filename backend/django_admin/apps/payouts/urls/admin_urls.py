from django.urls import path

from ..views.api import PayoutDetailView, PayoutListView

urlpatterns = [
    path('', PayoutListView.as_view(), name='admin-payout-list'),
    path('<uuid:uuid>/', PayoutDetailView.as_view(), name='admin-payout-detail'),
]