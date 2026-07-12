# backend/django_admin/apps/notifications/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from django.utils import timezone
from ..models import Notification, NotificationPreference
from ..serializers import NotificationSerializer, MarkReadSerializer, NotificationPreferenceSerializer


class UserNotificationListView(generics.ListAPIView):
    """List authenticated user's notifications."""
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user).order_by('-created_at')


class MarkNotificationsReadView(generics.GenericAPIView):
    """Mark one or multiple notifications as read."""
    serializer_class = MarkReadSerializer
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        n_ids = serializer.validated_data['notification_ids']
        Notification.objects.filter(id__in=n_ids, user=request.user).update(is_read=True, read_at=timezone.now())
        return Response({'status': 'updated'}, status=status.HTTP_200_OK)


class NotificationPreferenceListView(generics.ListCreateAPIView):
    serializer_class = NotificationPreferenceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return NotificationPreference.objects.filter(user=self.request.user).order_by('channel', 'category')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class NotificationPreferenceDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = NotificationPreferenceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return NotificationPreference.objects.filter(user=self.request.user)