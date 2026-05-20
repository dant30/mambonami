# backend/django_admin/config/urls.py
from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse

def health_check(request):
    return JsonResponse({"status": "ok"})

urlpatterns = [
    path('health/', health_check, name='health'),
    path('admin/', admin.site.urls),
    path('api/users/', include('apps.users.urls')),
    path('api/paybill/', include('apps.paybill.urls')),
    path('api/products/', include('apps.products.urls')),
    path('api/orders/', include('apps.orders.urls')),
    path('api/logistics/', include('apps.logistics.urls')),
    path('api/payouts/', include('apps.payouts.urls')),
    path('api/disputes/', include('apps.disputes.urls')),
    path('api/notifications/', include('apps.notifications.urls')),
    path('api/audit/', include('apps.audit.urls')),
    path('api/analytics/', include('apps.analytics.urls')),
]
