# backend/django_admin/apps/audit/services/logger.py
# backend/django_admin/apps/audit/services/logger.py
import json
import logging
import re
from typing import Optional, Any, Dict
from django.db import transaction
from django.utils.timezone import now
from ..models import AuditLog, SecurityEvent

logger = logging.getLogger(__name__)
SENSITIVE_METADATA_KEYS = (
    'password', 'token', 'secret', 'otp', 'pin', 'authorization', 'credential',
    'apikey', 'privatekey', 'cookie', 'session',
)

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


def log_security_event(
    event_type: str,
    description: str,
    severity: str = SecurityEvent.Severity.MEDIUM,
    user=None,
    request=None,
    metadata: Optional[Dict[str, Any]] = None,
) -> SecurityEvent:
    """Persist a security event without retaining credential-like metadata."""
    event = SecurityEvent(
        event_type=event_type,
        description=description,
        severity=severity,
        user=user if user and getattr(user, 'is_authenticated', False) else None,
        metadata=_redact_metadata(metadata or {}),
    )
    if request:
        event.ip_address = _get_client_ip(request)
        event.request_id = getattr(request, 'request_id', '')
    event.save()
    logger.warning('Security event recorded: %s (%s)', event.event_type, event.severity)
    return event


def _redact_metadata(value):
    if isinstance(value, dict):
        redacted = {}
        for key, item in value.items():
            normalized_key = re.sub(r'[^a-z0-9]', '', str(key).lower())
            if any(sensitive_key in normalized_key for sensitive_key in SENSITIVE_METADATA_KEYS):
                redacted[str(key)] = '[REDACTED]'
            else:
                redacted[str(key)] = _redact_metadata(item)
        return redacted
    if isinstance(value, list):
        return [_redact_metadata(item) for item in value]
    if isinstance(value, tuple):
        return [_redact_metadata(item) for item in value]
    return value

def _get_client_ip(request):
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip