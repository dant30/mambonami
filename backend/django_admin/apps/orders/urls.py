# backend/django_admin/apps/orders/urls.py
from django.urls import path
from .views import api

urlpatterns = [
    # Order creation & retrieval
    path('cart/create-order/', api.CartCreateOrderView.as_view(), name='create-order'),
    path('<uuid:uuid>/', api.OrderDetailView.as_view(), name='order-detail'),

    # Farmer actions
    path('suborder/<int:suborder_id>/confirm/', api.FarmerConfirmSubOrderView.as_view(), name='farmer-confirm'),
    path('suborder/<int:suborder_id>/ready/', api.FarmerReadyView.as_view(), name='farmer-ready'),

    # Transport provider actions
    path('<uuid:order_uuid>/generate-otp/', api.GenerateDeliveryOTPView.as_view(), name='generate-otp'),

    # Buyer verification
    path('<uuid:order_uuid>/verify-delivery/', api.VerifyDeliveryOTPView.as_view(), name='verify-delivery'),
]