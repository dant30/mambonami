# backend/django_admin/apps/notifications/services/push.py
import logging
import firebase_admin
from firebase_admin import credentials, messaging
from django.conf import settings
from ..models import Notification

logger = logging.getLogger(__name__)

class PushNotificationService:
    def __init__(self):
        if not firebase_admin._apps:
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred)

    def send(self, notification: Notification) -> bool:
        """Send push notification via FCM."""
        # User must have a device registration token stored
        # We assume user has a field 'fcm_token' or a related model.
        # For MVP, we'll skip if no token.
        fcm_token = getattr(notification.user, 'fcm_token', None)
        if not fcm_token:
            notification.status = 'failed'
            notification.error_message = "User has no FCM token"
            notification.save(update_fields=['status', 'error_message'])
            return False

        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=notification.title,
                    body=notification.body
                ),
                token=fcm_token,
                data=notification.metadata,
            )
            response = messaging.send(message)
            notification.external_id = response
            notification.status = 'sent'
            notification.delivered_at = timezone.now()
            notification.save(update_fields=['external_id', 'status', 'delivered_at'])
            logger.info(f"Push sent to {fcm_token}: {response}")
            return True
        except Exception as e:
            notification.status = 'failed'
            notification.error_message = str(e)
            notification.save(update_fields=['status', 'error_message'])
            logger.error(f"Push failed: {e}")
            return False