# backend/django_admin/apps/audit/models/audit_log.py
# backend/django_admin/apps/audit/models/audit_log.py
from django.db import models
from shared.db_models.base import BaseModel
from django.conf import settings

class AuditLog(BaseModel):
    """Immutable log of admin actions and critical data changes."""
    ACTION_TYPES = [
        ('CREATE', 'Create'),
        ('UPDATE', 'Update'),
        ('DELETE', 'Delete'),
        ('LOGIN', 'Login'),
        ('LOGOUT', 'Logout'),
        ('APPROVE', 'Approve'),
        ('REJECT', 'Reject'),
        ('RESOLVE', 'Resolve'),
        ('REFUND', 'Refund'),
        ('PAYOUT', 'Payout'),
        ('VIEW', 'View'),
        ('EXPORT', 'Export'),
    ]

    # Who did it
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name='audit_logs')
    user_ip = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)

    # What they did
    action = models.CharField(max_length=20, choices=ACTION_TYPES, db_index=True)
    model_name = models.CharField(max_length=100, help_text="e.g., 'orders.Order', 'users.User'")
    object_id = models.CharField(max_length=50, help_text="Primary key of the affected object")
    object_repr = models.CharField(max_length=200, blank=True, help_text="String representation of the object")
    changes = models.JSONField(default=dict, help_text="Diff of changes (old → new)")

    # When and where
    timestamp = models.DateTimeField(auto_now_add=True, db_index=True)
    request_id = models.CharField(max_length=100, blank=True, help_text="Correlation ID from middleware")
    endpoint = models.CharField(max_length=255, blank=True)

    class Meta:
        db_table = 'audit_logs'
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['user', 'timestamp']),
            models.Index(fields=['model_name', 'object_id']),
            models.Index(fields=['action', 'timestamp']),
        ]

    def __str__(self):
        return f"{self.timestamp} | {self.user} | {self.action} | {self.model_name}#{self.object_id}"

    def save(self, *args, **kwargs):
        """Ensure immutability: never update existing row."""
        if self.pk:
            raise RuntimeError("AuditLog entries cannot be updated after creation.")
        super().save(*args, **kwargs)


class SecurityEvent(BaseModel):
    class Severity(models.TextChoices):
        LOW = 'low', 'Low'
        MEDIUM = 'medium', 'Medium'
        HIGH = 'high', 'High'
        CRITICAL = 'critical', 'Critical'

    event_type = models.CharField(max_length=100, db_index=True)
    description = models.TextField()
    severity = models.CharField(max_length=10, choices=Severity.choices, default=Severity.MEDIUM, db_index=True)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='security_events',
    )
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    request_id = models.CharField(max_length=100, blank=True, db_index=True)
    investigated = models.BooleanField(default=False, db_index=True)
    investigation_notes = models.TextField(blank=True)
    resolved_at = models.DateTimeField(null=True, blank=True)
    metadata = models.JSONField(default=dict, blank=True)

    class Meta:
        db_table = 'security_events'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['event_type', 'created_at'], name='audit_sec_event_created_idx'),
            models.Index(fields=['severity', 'investigated', 'created_at'], name='audit_sec_sev_inv_created_idx'),
        ]

    def __str__(self):
        return f'{self.created_at} - {self.event_type} ({self.severity})'