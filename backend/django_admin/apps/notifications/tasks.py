# backend/django_admin/apps/notifications/tasks.py
from celery import shared_task
from django.utils import timezone
from .models import Notification
from .services.whatsapp import WhatsAppService
from .services.email import EmailService
from .services.push import PushNotificationService

@shared_task(bind=True, max_retries=3)
def send_notification_task(self, notification_id):
    try:
        notif = Notification.objects.get(id=notification_id)
        if notif.status != 'pending':
            return
        if notif.channel == 'whatsapp':
            service = WhatsAppService()
        elif notif.channel == 'email':
            service = EmailService()
        elif notif.channel == 'push':
            service = PushNotificationService()
        else:
            # In-app: just mark as sent (already stored)
            notif.status = 'sent'
            notif.delivered_at = timezone.now()
            notif.save(update_fields=['status', 'delivered_at'])
            return
        service.send(notif)
    except Notification.DoesNotExist:
        pass
    except Exception as e:
        # Retry in 60 seconds if not already retried too many times
        self.retry(exc=e, countdown=60)