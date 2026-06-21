# backend/django_admin/apps/notifications/models/notification.py
from django.db import models
from django.utils import timezone
from shared.db_models.base import BaseModel
from apps.users.models import User

class Notification(BaseModel):
    """Log of a notification sent to a user."""
    CHANNEL_CHOICES = [
        ('whatsapp', 'WhatsApp'),
        ('email', 'Email'),
        ('push', 'Push Notification'),
        ('in_app', 'In-App'),
    ]
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('sent', 'Sent'),
        ('failed', 'Failed'),
        ('read', 'Read'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    channel = models.CharField(max_length=20, choices=CHANNEL_CHOICES)
    title = models.CharField(max_length=200)
    body = models.TextField()
    metadata = models.JSONField(default=dict, help_text="Extra data (order_id, dispute_id, etc.)")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', db_index=True)
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