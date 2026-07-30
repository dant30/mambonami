# backend/django_admin/apps/users/urls/__init__.py
from .urls import app_name, urlpatterns as user_urls
from .admin_urls import urlpatterns as admin_urls

urlpatterns = user_urls

__all__ = ['app_name', 'user_urls', 'admin_urls', 'urlpatterns']