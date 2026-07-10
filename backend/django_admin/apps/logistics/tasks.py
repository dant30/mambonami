# backend/django_admin/apps/logistics/tasks.py
from celery import shared_task
from django.utils import timezone
from datetime import timedelta
from .models import Trip

@shared_task
def auto_cancel_unassigned_trips():
    """
    Cancel trips that are still 'offered' or 'accepted' but not picked up after 2 hours.
    """
    cutoff = timezone.now() - timedelta(hours=2)
    stale = Trip.objects.filter(
        status__in=['offered', 'accepted'],
        created_at__lt=cutoff
    )
    count = stale.update(status='cancelled')
    return f"Cancelled {count} stale trips (offered/accepted over 2 hours)."


@shared_task
def cleanup_expired_otp():
    """Clear OTP codes for trips older than 30 minutes after expiry."""
    expired = Trip.objects.filter(otp_expires_at__lt=timezone.now()).exclude(otp_code='')
    count = expired.update(otp_code='')
    return f"Cleared {count} expired OTPs."