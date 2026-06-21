# backend/django_admin/config/settings/prod.py
from .base import *

DEBUG = False
ALLOWED_HOSTS = env.list('DJANGO_ALLOWED_HOSTS', default=['mambonami.com', 'www.mambonami.com', 'api.mambonami.com'])
USE_S3 = True

# Security
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
CSRF_COOKIE_HTTPONLY = True
USE_X_FORWARDED_HOST = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_BROWSER_XSS_FILTER = True
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
X_FRAME_OPTIONS = 'DENY'

# CSRF trusted origins
CSRF_TRUSTED_ORIGINS = env.list('CSRF_TRUSTED_ORIGINS', default=[
    'https://api.mambonami.com',
    'https://admin.mambonami.com',
])

# CORS – restrict to production domains
CORS_ALLOW_ALL_ORIGINS = False
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS', default=[
    'https://mambonami.com',
    'https://api.mambonami.com',
    'https://admin.mambonami.com',
])

# Static / Media – use S3 or WhiteNoise
STATICFILES_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'
DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'
AWS_ACCESS_KEY_ID = env('AWS_ACCESS_KEY_ID', default='')
AWS_SECRET_ACCESS_KEY = env('AWS_SECRET_ACCESS_KEY', default='')
AWS_STORAGE_BUCKET_NAME = env('AWS_STORAGE_BUCKET_NAME', default='')
AWS_S3_REGION_NAME = env('AWS_S3_REGION_NAME', default='eu-west-1')
AWS_QUERYSTRING_AUTH = False

# Alternatively use WhiteNoise for static files:
# STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Email (e.g., SendGrid)
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.sendgrid.net'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'apikey'
EMAIL_HOST_PASSWORD = env('SENDGRID_API_KEY', default='')
DEFAULT_FROM_EMAIL = 'noreply@mambonami.com'

# Logging – file only, no console in production
LOGGING['handlers']['console']['level'] = 'ERROR'   # reduce noise
LOGGING['loggers']['django']['handlers'] = ['file']
LOGGING['loggers']['apps.paybill']['handlers'] = ['file']
LOGGING['root']['handlers'] = ['file']

# Celery broker – use production Redis URL
CELERY_BROKER_URL = env('REDIS_URL', default='redis://localhost:6379/0')
CACHES['default']['LOCATION'] = env('REDIS_URL', default='redis://localhost:6379/0')

# M-Pesa – use production credentials
MPESA_ENVIRONMENT = 'production'

SESSION_COOKIE_DOMAIN = 'api.mambonami.com'