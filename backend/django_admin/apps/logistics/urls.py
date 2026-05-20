# backend/django_admin/apps/logistics/urls.py
from django.urls import path
from .views import api

urlpatterns = [
    # Provider endpoints
    path('orders/available/', api.AvailableOrdersView.as_view(), name='available-orders'),
    path('orders/<int:order_id>/assign/', api.AssignToMeView.as_view(), name='assign-to-me'),
    path('my-trips/', api.ProviderTripListView.as_view(), name='my-trips'),
    path('my-trips/<uuid:uuid>/', api.ProviderTripDetailView.as_view(), name='trip-detail'),
    path('my-trips/<uuid:trip_uuid>/generate-otp/', api.GenerateOTPView.as_view(), name='generate-otp'),
    
    # Buyer endpoint
    path('trips/<uuid:trip_uuid>/verify-otp/', api.VerifyOTPView.as_view(), name='verify-otp'),
]