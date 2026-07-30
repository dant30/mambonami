# backend/django_admin/apps/logistics/urls.py
from django.urls import path
from .views import api

app_name = 'logistics'

urlpatterns = [
    # Provider flows (with detailed status transitions)
    path('orders/available/', api.AvailableOrdersView.as_view(), name='available-orders'),
    path('trips/<uuid:trip_uuid>/assign/', api.AssignToMeView.as_view(), name='assign-to-me'),
    path('trips/<uuid:trip_uuid>/start-pickup-nav/', api.TripStartNavigationPickupView.as_view(), name='start-pickup-nav'),
    path('trips/<uuid:trip_uuid>/arrive-pickup/', api.TripArriveAtPickupView.as_view(), name='arrive-pickup'),
    path('trips/<uuid:trip_uuid>/pickup/', api.TripPickupView.as_view(), name='pickup'),
    path('trips/<uuid:trip_uuid>/start-delivery-nav/', api.TripStartNavigationDeliveryView.as_view(), name='start-delivery-nav'),
    path('trips/<uuid:trip_uuid>/arrive-delivery/', api.TripArriveAtDeliveryView.as_view(), name='arrive-delivery'),
    path('trips/<uuid:trip_uuid>/generate-otp/', api.GenerateOTPView.as_view(), name='generate-otp'),
    
    # Provider views
    path('my-trips/', api.ProviderTripListView.as_view(), name='my-trips'),
    path('my-trips/<uuid:uuid>/', api.ProviderTripDetailView.as_view(), name='trip-detail'),
    path('my-trips/<uuid:trip_uuid>/location/', api.TripLocationPingView.as_view(), name='trip-location'),
    path('my-trips/<uuid:trip_uuid>/media/', api.TripMediaUploadView.as_view(), name='trip-media-upload'),
    
    # Buyer endpoints
    path('trips/<uuid:trip_uuid>/verify-otp/', api.VerifyOTPView.as_view(), name='verify-otp'),
    path('buyer/trips/<uuid:uuid>/', api.BuyerTripDetailView.as_view(), name='buyer-trip-detail'),
    
    # Admin endpoints
    path('admin/trips/', api.AdminTripListView.as_view(), name='admin-trip-list'),
    path('admin/trips/<uuid:uuid>/', api.AdminTripDetailView.as_view(), name='admin-trip-detail'),
    path('admin/trips/<uuid:trip_uuid>/cancel/', api.AdminCancelTripView.as_view(), name='admin-cancel-trip'),
]