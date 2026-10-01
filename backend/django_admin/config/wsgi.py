# backend/django_admin/config/wsgi.py
"""
WSGI config for MAMBONAMI project.
It exposes the WSGI callable as a module-level variable named ``application``.
For more information on this file, see
https://docs.djangoproject.com/en/4.2/howto/deployment/wsgi/
"""

import os
import sys
from django.core.wsgi import get_wsgi_application

# Add project root (where 'shared' and 'backend' live)
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, PROJECT_ROOT)
# Also add the directory containing 'apps' (django_admin) if needed
sys.path.insert(0, os.path.join(PROJECT_ROOT, 'backend', 'django_admin'))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.prod')

application = get_wsgi_application()