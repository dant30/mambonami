# backend/django_admin/apps/notifications/tasks.py
from celery import shared_task
from django.utils import timezone
from .models import Notification
from .services.whatsapp import WhatsAppService
from .services.email import EmailService
from .services.push import PushNotificationService
from .services.sms import OTSSMS

@shared_task(bind=True, max_retries=3)
def send_notification_task(self, notification_id):
    try:
        notif = Notification.objects.get(id=notification_id)
        if notif.delivery_status != Notification.DeliveryStatus.PENDING:
            return
        if notif.channel == Notification.Channel.WHATSAPP:
            service = WhatsAppService()
        elif notif.channel == Notification.Channel.EMAIL:
            service = EmailService()
        elif notif.channel == Notification.Channel.PUSH:
            service = PushNotificationService()
        elif notif.channel == Notification.Channel.SMS:
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