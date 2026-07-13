# backend/django_admin/config/celery.py
import os
from celery import Celery
from celery.schedules import crontab
from celery.signals import setup_logging

# Set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.dev')

app = Celery('mambonami')

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Load task modules from all registered Django apps.
app.autodiscover_tasks()

app.conf.beat_schedule = {
    'aggregate-daily-metrics': {
        'task': 'apps.analytics.tasks.aggregate_today_metrics',
        'schedule': crontab(hour=0, minute=5),  # 00:05 every day
    },
    'update-provider-reliability': {
        'task': 'apps.logistics.tasks.update_provider_reliability_metrics',
        'schedule': 86400.0,  # once per day
    },
    'auto-cancel-stale-trips': {
        'task': 'apps.logistics.tasks.auto_cancel_unassigned_trips',
        'schedule': 3600.0,   # every hour
    },
    'cleanup-expired-otp': {
        'task': 'apps.logistics.tasks.cleanup_expired_otp',
        'schedule': 1800.0,   # every 30 minutes
    },
    'check-low-stock-products': {
        'task': 'apps.products.tasks.check_low_stock_products',
        'schedule': crontab(hour='*/6', minute=0),
    },
    'check-expiring-products': {
        'task': 'apps.products.tasks.check_expiring_products',
        'schedule': crontab(hour='*/6', minute=15),
    },
}

@setup_logging.connect
def config_loggers(*args, **kwargs):
    """Disable Celery's default logging setup to let Django handle logging."""
    pass

@app.task(bind=True, ignore_result=True)
def debug_task(self):
    print(f'Request: {self.request!r}')