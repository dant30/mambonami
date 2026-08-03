# backend/django_admin/apps/paybill/urls.py
from django.urls import path
from .views import api

app_name = 'paybill'

urlpatterns = [
    path('mpesa/callback/', api.IPNCallbackView.as_view(), name='mpesa_callback'),
    path('c2b/validation/', api.C2BValidationCallbackView.as_view(), name='c2b_validation'),
    path('c2b/confirmation/', api.C2BConfirmationCallbackView.as_view(), name='c2b_confirmation'),
    path('simulate/', api.PayBillSimulationView.as_view(), name='paybill_simulate'),
    path('transactions/', api.PayBillTransactionListView.as_view(), name='paybill_transactions'),
    path('settlements/', api.PayBillSettlementListView.as_view(), name='paybill_settlements'),
    path('float-balance/', api.FloatBalanceView.as_view(), name='float_balance'),
]
