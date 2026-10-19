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

# Media is stored in S3-compatible DigitalOcean Spaces. Static assets remain
# local and are served by Nginx; verification documents use a separate private Space.
if not all((
    DO_SPACES_PUBLIC_ACCESS_KEY,
    DO_SPACES_PUBLIC_SECRET_KEY,
    DO_SPACES_PRIVATE_ACCESS_KEY,
    DO_SPACES_PRIVATE_SECRET_KEY,
    DO_SPACES_PUBLIC_BUCKET,
    DO_SPACES_PRIVATE_BUCKET,
)):
    raise RuntimeError(
        'Production media storage requires separate public/private Spaces keys and buckets.'
    )
if DO_SPACES_PUBLIC_BUCKET == DO_SPACES_PRIVATE_BUCKET:
    raise RuntimeError('Public media and verification documents must use separate Spaces buckets.')

USE_S3 = True

STORAGES = {
    'default': {
        'BACKEND': 'core.storage_backends.SpacesPublicMediaStorage',
    },
    'staticfiles': {
        'BACKEND': 'django.contrib.staticfiles.storage.StaticFilesStorage',
    },
}

# Alternatively use WhiteNoise for static files:
# STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Email (e.g., SendGrid)
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.zoho.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'noreply@mambonami.com'
EMAIL_HOST_PASSWORD = env('SENDGRID_API_KEY', default='')
DEFAULT_FROM_EMAIL = 'noreply@mambonami.com'

# Logging – file only, no console in production
LOGGING['handlers']['console']['level'] = 'ERROR'   # reduce noise
LOGGING['loggers']['django']['handlers'] = ['file']
LOGGING['loggers']['apps.paybill']['handlers'] = ['file']
LOGGING['root']['handlers'] = ['file']
LOGGING['loggers']['middleware'] = {
    'handlers': ['console', 'file'],
    'level': 'ERROR',
    'propagate': False,
}

# Celery broker – use production Redis URL
CELERY_BROKER_URL = env('REDIS_URL', default='redis://localhost:6379/0')

# Ensure production uses Redis for Django cache (OTP and other shared cache state)
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://localhost:6379/0'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        },
    }
}

# M-Pesa – use production credentials
MPESA_ENVIRONMENT = 'production'

SESSION_COOKIE_DOMAIN = 'api.mambonami.com'