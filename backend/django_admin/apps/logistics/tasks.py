# backend/django_admin/apps/logistics/tasks.py
from celery import shared_task
from django.utils import timezone
from datetime import timedelta
from .models import Trip

@shared_task
def auto_cancel_unassigned_trips():
    """Cancel trips that have been 'assigned' for more than 2 hours without pickup."""
    cutoff = timezone.now() - timedelta(hours=2)
    stale = Trip.objects.filter(status='assigned', created_at__lt=cutoff)
    count = stale.update(status='cancelled')
    return f"Cancelled {count} stale trips."

@shared_task
def cleanup_expired_otp():
    """Clear OTP codes for trips older than 30 minutes after expiry."""
    expired = Trip.objects.filter(otp_expires_at__lt=timezone.now()).exclude(otp_code='')
    count = expired.update(otp_code='')
    return f"Cleared {count} expired OTPs."