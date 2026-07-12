# backend/django_admin/apps/notifications/services/whatsapp.py
import logging
from twilio.rest import Client
from django.conf import settings
from django.utils import timezone
from ..models import Notification

logger = logging.getLogger(__name__)

class WhatsAppService:
    def __init__(self):
        self.client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        self.from_number = settings.TWILIO_WHATSAPP_FROM

    def send(self, notification: Notification) -> bool:
        """Send WhatsApp message via Twilio."""
        try:
            # Ensure phone number is in international format
            to_phone = notification.user.phone
            if not to_phone.startswith('+'):
                to_phone = f'+254{to_phone.lstrip("0")}'  # Kenyan default
            message = self.client.messages.create(
                from_=f'whatsapp:{self.from_number}',
                body=notification.body,
                to=f'whatsapp:{to_phone}'
            )
            notification.external_id = message.sid
            notification.delivery_status = Notification.DeliveryStatus.SENT
            notification.delivered_at = timezone.now()
            notification.save(update_fields=['external_id', 'delivery_status', 'delivered_at'])
            logger.info(f"WhatsApp sent to {to_phone}: {message.sid}")
            return True
        except Exception as e:
            notification.delivery_status = Notification.DeliveryStatus.FAILED
            notification.error_message = str(e)
            notification.save(update_fields=['delivery_status', 'error_message'])
            logger.error(f"WhatsApp failed: {e}")
            return False