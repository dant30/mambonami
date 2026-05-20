# backend/django_admin/apps/notifications/views/api.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from ..models import Notification
from ..serializers import NotificationSerializer, MarkReadSerializer

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
        Notification.objects.filter(id__in=n_ids, user=request.user).update(status='read', read_at=timezone.now())
        return Response({'status': 'updated'}, status=status.HTTP_200_OK)