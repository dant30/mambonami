# backend/django_admin/config/settings/dev.py
from .base import *

DEBUG = True
ALLOWED_HOSTS = ['*']

# Development database – optional override (use default from base)
# DATABASES['default'] = ... (you can use SQLite or local PostgreSQL)

if USE_S3:
    STORAGES = {
        'default': {
            'BACKEND': 'core.storage_backends.SpacesPublicMediaStorage',
        },
        'staticfiles': {
            'BACKEND': 'django.contrib.staticfiles.storage.StaticFilesStorage',
        },
    }

# Show emails in console instead of sending
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# CORS – allow all for local development
CORS_ALLOW_ALL_ORIGINS = True

# Logging to console with more detail
LOGGING['root']['level'] = 'DEBUG'
LOGGING['handlers']['console']['formatter'] = 'verbose'

# Disable HTTPS enforcement
SECURE_SSL_REDIRECT = False
SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False

# Celery always eager for local testing (optional)
# CELERY_TASK_ALWAYS_EAGER = True

# DRF – disable throttling for dev
REST_FRAMEWORK['DEFAULT_THROTTLE_RATES'] = {
    'anon': '10000/day',
    'user': '10000/day',
    'public_products': '10000/day',
    'public_categories': '10000/day',
    'public_product_detail': '10000/day',
}

# M-Pesa – force sandbox
MPESA_ENVIRONMENT = 'sandbox'