# backend/django_admin/apps/audit/services/logger.py
# backend/django_admin/apps/audit/services/logger.py
import json
import logging
from typing import Optional, Any, Dict
from django.db import transaction
from django.utils.timezone import now
from ..models import AuditLog

logger = logging.getLogger(__name__)

def log_action(
    user,
    action: str,
    model_name: str,
    object_id,
    object_repr: str = "",
    changes: Dict = None,
    request=None,
    commit: bool = True
) -> Optional[AuditLog]:
    """
    Create an audit log entry.

    Args:
        user: User instance or None (system action)
        action: one of AuditLog.ACTION_TYPES
        model_name: e.g., 'orders.Order'
        object_id: primary key of the affected object (string)
        object_repr: human-readable representation
        changes: dict of changes (old → new)
        request: optional HttpRequest to extract IP, user_agent, endpoint, request_id
        commit: if False, return unsaved instance for bulk create

    Returns:
        AuditLog instance (unsaved if commit=False)
    """
    data = {
        'user': user if user and user.is_authenticated else None,
        'action': action,
        'model_name': model_name,
        'object_id': str(object_id),
        'object_repr': object_repr,
        'changes': changes or {},
        'timestamp': now(),
    }

    if request:
        data['user_ip'] = _get_client_ip(request)
        data['user_agent'] = request.META.get('HTTP_USER_AGENT', '')[:1000]
        data['endpoint'] = request.build_absolute_uri()
        data['request_id'] = getattr(request, 'request_id', '')

    log_entry = AuditLog(**data)
    if commit:
        log_entry.save()
        logger.info(f"Audit log created: {log_entry}")
    return log_entry

def log_model_change(sender, instance, action, request=None, **kwargs):
    """Helper to log changes from Django signals."""
    model_name = f"{sender._meta.app_label}.{sender._meta.model_name}"
    object_id = instance.pk
    object_repr = str(instance)
    changes = {}
    if action == 'UPDATE' and hasattr(instance, '_changed_fields'):
        changes = {field: (getattr(instance, field, None)) for field in instance._changed_fields}
    log_action(
        user=getattr(request, 'user', None) if request else None,
        action=action,
        model_name=model_name,
        object_id=object_id,
        object_repr=object_repr,
        changes=changes,
        request=request,
        commit=True
    )

def _get_client_ip(request):
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip