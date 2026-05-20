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
}

@setup_logging.connect
def config_loggers(*args, **kwargs):
    """Disable Celery's default logging setup to let Django handle logging."""
    pass

@app.task(bind=True, ignore_result=True)
def debug_task(self):
    print(f'Request: {self.request!r}')