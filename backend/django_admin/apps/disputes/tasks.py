# backend/django_admin/apps/disputes/tasks.py
from celery import shared_task
from django.utils import timezone
from datetime import timedelta
from .models import Dispute

@shared_task
def auto_escalate_stale_disputes():
    """Escalate disputes that have been open > 7 days without admin action."""
    cutoff = timezone.now() - timedelta(days=7)
    stale = Dispute.objects.filter(status='open', created_at__lt=cutoff)
    count = stale.update(status='escalated')
    return f"Escalated {count} stale disputes."