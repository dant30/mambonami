# backend/django_admin/apps/notifications/urls.py
from django.urls import path
from .views import api

urlpatterns = [
    path('', api.UserNotificationListView.as_view(), name='user-notifications'),
    path('mark-read/', api.MarkNotificationsReadView.as_view(), name='mark-read'),
    path('preferences/', api.NotificationPreferenceListView.as_view(), name='notification-preferences-list'),
    path('preferences/<int:pk>/', api.NotificationPreferenceDetailView.as_view(), name='notification-preference-detail'),
]