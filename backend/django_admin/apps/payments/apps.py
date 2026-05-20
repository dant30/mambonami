# backend/django_admin/apps/payments/apps.py
from django.apps import AppConfig

class PaymentsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.payments'
    label = 'payments'

    def ready(self):
        # No signals to import yet
        pass