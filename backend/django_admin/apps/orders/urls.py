from django.urls import path
from .views import api

app_name = 'orders'

urlpatterns = [
    path('create/', api.CartCreateOrderView.as_view(), name='order-create'),
    path('', api.OrderListView.as_view(), name='order-list'),
    path('active/', api.ActiveOrderView.as_view(), name='active-order'),  # NEW
    path('<uuid:uuid>/', api.OrderDetailView.as_view(), name='order-detail'),
    path('suborders/', api.FarmerSubOrdersView.as_view(), name='farmer-suborders'),
    path('suborders/<int:suborder_id>/', api.FarmerSubOrderDetailView.as_view(), name='farmer-suborder-detail'),
    path('suborders/<int:suborder_id>/confirm/', api.FarmerConfirmSubOrderView.as_view(), name='farmer-suborder-confirm'),
    path('suborders/<int:suborder_id>/ready/', api.FarmerReadyView.as_view(), name='farmer-suborder-ready'),
    path('<uuid:order_uuid>/generate-otp/', api.GenerateDeliveryOTPView.as_view(), name='generate-otp'),
    path('<uuid:order_uuid>/verify-otp/', api.VerifyDeliveryOTPView.as_view(), name='verify-otp'),
]