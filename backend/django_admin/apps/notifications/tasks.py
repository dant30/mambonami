# backend/django_admin/apps/notifications/tasks.py
import logging

from celery import shared_task
from django.utils import timezone

from .models import Notification

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3)
def send_notification_task(self, notification_id):
    try:
        notif = Notification.objects.get(id=notification_id)
        if notif.delivery_status != Notification.DeliveryStatus.PENDING:
            return

        if notif.channel == Notification.Channel.WHATSAPP:
            try:
                from .services.whatsapp import WhatsAppService
            except Exception as exc:
                logger.exception("Unable to initialize WhatsApp notification service")
                notif.delivery_status = Notification.DeliveryStatus.FAILED
                notif.error_message = str(exc)
                notif.save(update_fields=['delivery_status', 'error_message'])
                return
            service = WhatsAppService()
        elif notif.channel == Notification.Channel.EMAIL:
            from .services.email import EmailService
            service = EmailService()
        elif notif.channel == Notification.Channel.PUSH:
            from .services.push import PushNotificationService
            service = PushNotificationService()
        elif notif.channel == Notification.Channel.SMS:
            from .services.sms import OTSSMS
            service = OTSSMS()
        else:
            notif.delivery_status = Notification.DeliveryStatus.SENT
            notif.delivered_at = timezone.now()
            notif.save(update_fields=['delivery_status', 'delivered_at'])
            return

        service.send(notif)
    except Notification.DoesNotExist:
        pass
    except Exception as e:
        self.retry(exc=e, countdown=60)