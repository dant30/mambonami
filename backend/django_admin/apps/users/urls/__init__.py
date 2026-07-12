# backend/django_admin/apps/users/urls/__init__.py
from .urls import urlpatterns as user_urls
from .admin_urls import urlpatterns as admin_urls

__all__ = ['user_urls', 'admin_urls']