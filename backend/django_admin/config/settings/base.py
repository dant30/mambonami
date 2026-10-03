# Django settings base
# backend/django_admin/config/settings/base.py
import os
from pathlib import Path
from datetime import timedelta
import environ

# Build paths inside the project like this: BASE_DIR / 'subdir'
BASE_DIR = Path(__file__).resolve().parent.parent.parent  # reaches django_admin/

# Environment variables
env = environ.Env()
environ.Env.read_env(os.path.join(BASE_DIR, '.env'))

# Quick-start development settings - overridden in dev/prod
SECRET_KEY = env('DJANGO_SECRET_KEY', default='django-insecure-dev-key-change-me')
DEBUG = False
ALLOWED_HOSTS = []

# Application definition
INSTALLED_APPS = [
    'jazzmin',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Third-party
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'drf_yasg',           # API documentation
    'django_filters',
    'django_celery_beat',
    'django_celery_results',

    # Local apps
    'apps.users.apps.UsersConfig',
    'apps.products.apps.ProductsConfig',
    'apps.orders.apps.OrdersConfig',
    'apps.payments.apps.PaymentsConfig',
    'apps.paybill.apps.PaybillConfig',
    'apps.payouts.apps.PayoutsConfig',
    'apps.logistics.apps.LogisticsConfig',
    'apps.disputes.apps.DisputesConfig',
    'apps.notifications.apps.NotificationsConfig',
    'apps.audit.apps.AuditConfig',
    'apps.analytics.apps.AnalyticsConfig',
]
JAZZMIN_SETTINGS = {
    'site_title': 'MAMBONAMI Admin',
    'site_header': 'MAMBONAMI Operations',
    'site_brand': 'MAMBONAMI',
    'welcome_sign': 'Marketplace operations',
    'copyright': 'MAMBONAMI',
    'show_sidebar': True,
    'navigation_expanded': False,
    'show_ui_builder': False,
    'search_model': [
        'users.User',
        'orders.Order',
        'products.Product',
        'paybill.PayBillTransaction',
    ],
    'topmenu_links': [
        {'name': 'Open marketplace', 'url': 'https://www.mambonami.com', 'new_window': True},
    ],
    'order_with_respect_to': [
        'orders', 'products', 'users', 'paybill', 'payouts', 'logistics',
        'disputes', 'notifications', 'analytics', 'audit', 'payments',
        'auth', 'django_celery_beat', 'django_celery_results', 'token_blacklist',
    ],
    'icons': {
        'orders': 'fas fa-shopping-basket',
        'products': 'fas fa-carrot',
        'users': 'fas fa-users',
        'paybill': 'fas fa-mobile-alt',
        'payouts': 'fas fa-money-bill-wave',
        'logistics': 'fas fa-truck',
        'disputes': 'fas fa-exclamation-triangle',
        'notifications': 'fas fa-bell',
        'analytics': 'fas fa-chart-line',
        'audit': 'fas fa-clipboard-list',
        'auth': 'fas fa-user-shield',
        'django_celery_beat': 'fas fa-clock',
        'django_celery_results': 'fas fa-tasks',
        'token_blacklist': 'fas fa-key',
    },
}

JAZZMIN_UI_TWEAKS = {
    'theme': 'flatly',
    'dark_mode_theme': 'darkly',
    'navbar': 'navbar-white navbar-light',
    'sidebar': 'sidebar-dark-primary',
    'brand_colour': 'navbar-success',
    'accent': 'accent-success',
    'sidebar_nav_flat_style': True,
    'sidebar_nav_compact_style': True,
}

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',     # CORS
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    # Custom middleware
    'core.middleware.CurrentUserMiddleware',
    'core.middleware.RequestIDMiddleware',
    'core.middleware.ExceptionHandlingMiddleware',
    'core.middleware.PerformanceLoggingMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

# Database - uses DATABASE_URL env variable
DATABASES = {
    'default': env.db('DATABASE_URL', default='postgresql://postgres:postgres@localhost:5432/mambonami')
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# Custom user model
AUTH_USER_MODEL = 'users.User'

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'Africa/Nairobi'
USE_I18N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_DIRS = [BASE_DIR / 'static']

# Media files (product images, proof of delivery photos)
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# REST Framework
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'core.authentication.CustomJWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
        'core.throttling.FarmerRateThrottle',
        'core.throttling.BuyerRateThrottle',
        'core.throttling.TransportProviderRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',
        'user': '1000/day',
    },
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}

# JWT Settings
SIMPLE_JWT = {
    'SIGNING_KEY': env('JWT_SECRET_KEY', default='django-insecure-jwt-key-change-me-to-32-bytes-minimum'),
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=2),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'AUTH_HEADER_TYPES': ('Bearer',),
}

# Storage & cache toggles
CACHE_TTL = env.int('CACHE_TTL', default=300)
USE_S3 = env.bool('USE_S3', default=False)

# CORS - allow all for dev; restrict in prod
CORS_ALLOW_ALL_ORIGINS = True  # override in prod
CORS_ALLOW_CREDENTIALS = True

# Celery Configuration
CELERY_BROKER_URL = env('REDIS_URL', default='redis://localhost:6379/0')
CELERY_RESULT_BACKEND = 'django-db'   # store results in database (django_celery_results)
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TIMEZONE = TIME_ZONE
CELERY_BEAT_SCHEDULER = 'django_celery_beat.schedulers:DatabaseScheduler'

# Cache
USE_REDIS = env.bool('USE_REDIS', default=False)
if USE_REDIS:
    CACHES = {
        'default': {
            'BACKEND': 'django_redis.cache.RedisCache',
            'LOCATION': env('REDIS_URL', default='redis://localhost:6379/1'),
            'OPTIONS': {
                'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            }
        }
    }
else:
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        }
    }

LOG_DIR = BASE_DIR / 'logs'
if not os.path.exists(LOG_DIR):
    os.makedirs(LOG_DIR)

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {asctime} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
        'file': {
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': BASE_DIR / 'logs' / 'mambonami.log',
            'maxBytes': 10485760,
            'backupCount': 5,
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': False,
        },
        'apps.paybill': {
            'handlers': ['console', 'file'],
            'level': 'DEBUG',
        },
    },
}

# M-Pesa Configuration (Safaricom)
MPESA_PAYBILL_NUMBER = env('MPESA_PAYBILL_NUMBER', default='123456')
MPESA_SHORTCODE_TYPE = 'paybill'
MPESA_CONSUMER_KEY = env('MPESA_CONSUMER_KEY', default='')
MPESA_CONSUMER_SECRET = env('MPESA_CONSUMER_SECRET', default='')
MPESA_PASSKEY = env('MPESA_PASSKEY', default='')          # for STK Push (if used later)
MPESA_ENVIRONMENT = env('MPESA_ENVIRONMENT', default='sandbox')  # 'sandbox' or 'production'

# B2C API (payouts)
MPESA_B2C_INITIATOR_NAME = env('MPESA_B2C_INITIATOR_NAME', default='')
MPESA_B2C_SECURITY_CREDENTIAL = env('MPESA_B2C_SECURITY_CREDENTIAL', default='')
MPESA_B2C_API_URL = env('MPESA_B2C_API_URL', default='https://sandbox.safaricom.co.ke/mpesa/b2c/v1/paymentrequest')
MPESA_ENVIRONMENT_URL = env('MPESA_ENVIRONMENT_URL', default='https://sandbox.safaricom.co.ke')
CALLBACK_BASE_URL = env('CALLBACK_BASE_URL', default='https://api.mambonami.com')

# Platform commission (MVP)
PLATFORM_COMMISSION_PERCENT = 8  # 8%
DELIVERY_PLATFORM_PERCENT = 20   # 20%

# OTP settings
OTP_LENGTH = 6
OTP_EXPIRY_SECONDS = 300  # 5 minutes
OTP_MAX_ATTEMPTS = 3

# Escrow reserve floor (KES)
ESCROW_RESERVE_FLOOR = 200_000

# SMS / WhatsApp / Email / Push (placeholders)
# OTS SMS Gateway (Olympus Telecom Solutions)
# https://sms.ots.co.ke/developers
OTS_API_URL = env('OTS_API_URL', default='https://sms.ots.co.ke/api/v3/')
OTS_API_TOKEN = env('OTS_API_TOKEN', default='')
OTS_SENDER_ID = env('OTS_SENDER_ID', default='MAMBONAMI')
OTS_SANDBOX = env.bool('OTS_SANDBOX', default=True)
# Add debug flag to help diagnose SMS provider auth and routing during development
OTS_DEBUG = env.bool('OTS_DEBUG', default=False)
WHATSAPP_API_URL = env('WHATSAPP_API_URL', default='')
WHATSAPP_API_TOKEN = env('WHATSAPP_API_TOKEN', default='')

# Twilio WhatsApp
TWILIO_ACCOUNT_SID = env('TWILIO_ACCOUNT_SID', default='')
TWILIO_AUTH_TOKEN = env('TWILIO_AUTH_TOKEN', default='')
TWILIO_WHATSAPP_FROM = env('TWILIO_WHATSAPP_FROM', default='+14155238886')

# SendGrid
SENDGRID_API_KEY = env('SENDGRID_API_KEY', default='')
DEFAULT_FROM_EMAIL = env('DEFAULT_FROM_EMAIL', default='noreply@mambonami.com')

# Firebase (store JSON credentials path)
FIREBASE_CREDENTIALS = env('FIREBASE_CREDENTIALS', default='')
FIREBASE_CREDENTIALS_PATH = env('FIREBASE_CREDENTIALS_PATH', default='config/firebase-credentials.json')