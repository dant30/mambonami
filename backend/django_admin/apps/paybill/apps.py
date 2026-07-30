from django.apps import AppConfig

class PaybillConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.paybill'
    label = 'paybill'
    verbose_name = 'Paybill'

    def ready(self):
        import apps.paybill.signals