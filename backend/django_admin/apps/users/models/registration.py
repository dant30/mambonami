import uuid

from django.contrib.auth.hashers import check_password
from django.db import models
from django.utils import timezone

from shared.db_models.base import BaseModel


class PendingRegistration(BaseModel):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('verified', 'Verified'),
        ('expired', 'Expired'),
        ('blocked', 'Blocked'),
        ('cancelled', 'Cancelled'),
    ]

    registration_id = models.UUIDField(default=uuid.uuid4, unique=True, editable=False, db_index=True)
    phone = models.CharField(max_length=15, db_index=True)
    role = models.CharField(max_length=30)
    registration_data = models.JSONField(default=dict)
    password_hash = models.CharField(max_length=256)
    otp_hash = models.CharField(max_length=128)
    otp_expires_at = models.DateTimeField()
    attempt_count = models.PositiveSmallIntegerField(default=0)
    resend_count = models.PositiveSmallIntegerField(default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', db_index=True)
    verified_at = models.DateTimeField(null=True, blank=True)

    def is_expired(self):
        return timezone.now() >= self.otp_expires_at

    def check_otp(self, otp):
        return check_password(otp, self.otp_hash)

    class Meta:
        db_table = 'pending_registrations'
        ordering = ['-created_at']
