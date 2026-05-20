# backend/django_admin/apps/notifications/urls.py
from django.urls import path
from .views import api

urlpatterns = [
    path('', api.UserNotificationListView.as_view(), name='user-notifications'),
    path('mark-read/', api.MarkNotificationsReadView.as_view(), name='mark-read'),
]