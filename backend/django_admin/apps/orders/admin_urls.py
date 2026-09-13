from django.urls import path

from .views.admin_views import AdminOrderDetailView, AdminOrderListView, AdminOrderStatusView

app_name = 'admin_orders'

urlpatterns = [
    path('', AdminOrderListView.as_view(), name='order-list'),
    path('<uuid:uuid>/', AdminOrderDetailView.as_view(), name='order-detail'),
    path('<uuid:uuid>/status/', AdminOrderStatusView.as_view(), name='order-status'),
]