# backend/django_admin/apps/audit/tasks.py
# backend/django_admin/apps/audit/tasks.py
from celery import shared_task
from django.core.management import call_command

@shared_task
def archive_old_audit_logs(days=90):
    """Call management command to archive logs older than `days`."""
    call_command('archive_audit_logs', days=days)

@shared_task
def cleanup_audit_logs(days=365):
    """Hard delete logs older than 1 year (optional)."""
    from .models import AuditLog
    from django.utils.timezone import now
    from datetime import timedelta
    cutoff = now() - timedelta(days=days)
    count, _ = AuditLog.objects.filter(timestamp__lt=cutoff).delete()
    return f"Deleted {count} old audit logs."