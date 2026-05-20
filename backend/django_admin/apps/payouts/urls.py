# backend/django_admin/apps/payouts/urls.py
from django.urls import path
from .views import api

urlpatterns = [
    path('', api.PayoutListView.as_view(), name='payout-list'),
    path('<uuid:uuid>/', api.PayoutDetailView.as_view(), name='payout-detail'),
    path('b2c/result/', api.B2CResultCallbackView.as_view(), name='b2c-result'),
    path('b2c/timeout/', api.B2CTimeoutCallbackView.as_view(), name='b2c-timeout'),
]