# backend/django_admin/apps/payments/urls.py
from django.urls import path
from .views import api

app_name = 'payments'

urlpatterns = [
    path('health/', api.PaymentHealthView.as_view(), name='payment-health'),
]