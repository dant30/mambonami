# backend/django_admin/config/urls.py
from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse
from rest_framework_simplejwt.views import TokenRefreshView, TokenVerifyView

def health_check(request):
    return JsonResponse({"status": "ok"})

urlpatterns = [
    path('health/', health_check, name='health'),
    path('admin/', admin.site.urls),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/token/verify/', TokenVerifyView.as_view(), name='token_verify'),
    path('api/users/', include(('apps.users.urls', 'users'), namespace='users')),
    path('admin-api/users/', include(('apps.users.urls.admin_urls', 'admin_users'), namespace='admin_users')),
    path('admin-api/audit/', include(('apps.audit.urls.admin_urls', 'admin_audit'), namespace='admin_audit')),
    path('admin-api/disputes/', include(('apps.disputes.urls.admin_urls', 'admin_disputes'), namespace='admin_disputes')),
    path('admin-api/payouts/', include(('apps.payouts.urls.admin_urls', 'admin_payouts'), namespace='admin_payouts')),
    path('api/paybill/', include(('apps.paybill.urls', 'paybill'), namespace='paybill')),
    path('api/products/', include(('apps.products.urls', 'products'), namespace='products')),
    path('api/orders/', include(('apps.orders.urls', 'orders'), namespace='orders')),
    path('api/logistics/', include(('apps.logistics.urls', 'logistics'), namespace='logistics')),
    path('api/payouts/', include(('apps.payouts.urls', 'payouts'), namespace='payouts')),
    path('api/disputes/', include(('apps.disputes.urls', 'disputes'), namespace='disputes')),
    path('api/notifications/', include(('apps.notifications.urls', 'notifications'), namespace='notifications')),
    path('api/audit/', include(('apps.audit.urls', 'audit'), namespace='audit')),
    path('api/analytics/', include(('apps.analytics.urls', 'analytics'), namespace='analytics')),
]
