# django_admin/apps/logistics/apps.py
# backend/django_admin/apps/logistics/apps.py
from django.apps import AppConfig

class LogisticsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.logistics'
    label = 'logistics'
    verbose_name = 'Logistics'

    def ready(self):
        import apps.logistics.signals