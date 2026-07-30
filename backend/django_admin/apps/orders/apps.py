# backend/django_admin/apps/orders/apps.py
from django.apps import AppConfig

class OrdersConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.orders'
    label = 'orders'
    verbose_name = 'Orders'

    def ready(self):
        import apps.orders.signals