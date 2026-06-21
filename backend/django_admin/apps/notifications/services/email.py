# backend/django_admin/apps/notifications/services/email.py
import logging
from django.core.mail import send_mail as django_send_mail
from django.conf import settings
from django.utils import timezone
from ..models import Notification

logger = logging.getLogger(__name__)

class EmailService:
    def __init__(self):
        self.use_sendgrid = hasattr(settings, 'SENDGRID_API_KEY') and settings.SENDGRID_API_KEY

    def send(self, notification: Notification) -> bool:
        """Send email using SendGrid or Django's mail backend."""
        to_email = notification.user.email
        if not to_email:
            notification.status = 'failed'
            notification.error_message = "User has no email address"
            notification.save(update_fields=['status', 'error_message'])
            return False

        try:
            if self.use_sendgrid:
                import sendgrid
                from sendgrid.helpers.mail import Mail
                sg = sendgrid.SendGridAPIClient(api_key=settings.SENDGRID_API_KEY)
                mail = Mail(
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    to_emails=to_email,
                    subject=notification.title,
                    plain_text_content=notification.body
                )
                response = sg.send(mail)
                notification.external_id = response.headers.get('X-Message-Id', '')
                success = response.status_code == 202
            else:
                # Fallback to Django's send_mail
                result = django_send_mail(
                    subject=notification.title,
                    message=notification.body,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[to_email],
                    fail_silently=False
                )
                success = result == 1
                notification.external_id = f"django_{notification.id}"

            if success:
                notification.status = 'sent'
                notification.delivered_at = timezone.now()
                notification.save(update_fields=['status', 'delivered_at', 'external_id'])
                logger.info(f"Email sent to {to_email}")
                return True
            else:
                raise Exception("Send failed")
        except Exception as e:
            notification.status = 'failed'
            notification.error_message = str(e)
            notification.save(update_fields=['status', 'error_message'])
            logger.error(f"Email failed: {e}")
            return False