# backend/django_admin/apps/paybill/urls.py
from django.urls import path
from apps.paybill.views import api

urlpatterns = [
    path('mpesa/callback/', api.IPNCallbackView.as_view(), name='mpesa_callback'),
    path('transactions/', api.PayBillTransactionListView.as_view(), name='paybill_transactions'),
]
