# backend/django_admin/apps/notifications/models/notification.py
from django.db import models
from django.utils import timezone
from shared.db_models.base import BaseModel
from django.conf import settings

class Notification(BaseModel):
    """Log of a notification sent to a user."""
    CHANNEL_CHOICES = [
        ('whatsapp', 'WhatsApp'),
        ('email', 'Email'),
        ('push', 'Push Notification'),
        ('sms', 'SMS'),
        ('in_app', 'In-App'),
    ]
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('sent', 'Sent'),
        ('failed', 'Failed'),
        ('read', 'Read'),
    ]
    NOTIFICATION_TYPES = [
        ('payment', 'Payment / Escrow'),
        ('order', 'Order Update'),
        ('delivery', 'Delivery Update'),
        ('review', 'New Review'),
        ('alert', 'Price / Market Alert'),
        ('system', 'System / Platform'),
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notifications')
    channel = models.CharField(max_length=20, choices=CHANNEL_CHOICES)
    title = models.CharField(max_length=200)
    body = models.TextField()
    type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='alert', help_text="Notification type for UI icon selection")
    metadata = models.JSONField(default=dict, help_text="Extra data (order_id, dispute_id, etc.)")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', db_index=True)
    notification_type = models.CharField(
        max_length=20,
        choices=NOTIFICATION_TYPES,
        default='system',
        db_index=True,
        help_text="Semantic type for UI icon/routing",
    )
    external_id = models.CharField(max_length=100, blank=True, help_text="Provider's message ID (Twilio, SendGrid, FCM)")
    error_message = models.TextField(blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    read_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'status']),
            models.Index(fields=['created_at']),
            models.Index(fields=['notification_type']),
        ]

    def __str__(self):
        return f"{self.user.phone} - {self.channel} - {self.title[:30]}"

    def mark_as_read(self):
        if not self.read_at:
            self.read_at = timezone.now()
            self.status = 'read'
            self.save(update_fields=['read_at', 'status'])


class NotificationTemplate(models.Model):
    """Predefined templates for messages."""
    CHANNEL_CHOICES = Notification.CHANNEL_CHOICES
    name = models.CharField(max_length=50, unique=True)
    channel = models.CharField(max_length=20, choices=CHANNEL_CHOICES)
    subject = models.CharField(max_length=200, blank=True)  # for email
    body_template = models.TextField(help_text="Use placeholders like {{order_id}}")
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'notification_templates'

    def __str__(self):
        return f"{self.name} ({self.channel})"

    def render(self, context: dict) -> str:
        """Render template with context."""
        from django.template import Template, Context
        tpl = Template(self.body_template)
        return tpl.render(Context(context))