from .urls import app_name, urlpatterns
from .admin_urls import urlpatterns as admin_urls

__all__ = ['app_name', 'urlpatterns', 'admin_urls']
