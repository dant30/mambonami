# backend/django_admin/apps/audit/signals.py
# backend/django_admin/apps/audit/signals.py
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.contrib.auth.signals import user_logged_in, user_logged_out, user_login_failed
from .services.logger import log_action
from .services.logger import log_security_event
from apps.users.models import User
from apps.orders.models import Order
from apps.logistics.models import Trip
from apps.payouts.models import Payout
from apps.disputes.models import Dispute

# Example: log user login (handled separately by middleware or auth signals)
# For model changes, we can use a generic signal, but we need to differentiate create/update.
# A robust approach: use django-auditlog or implement manually with pre/post save.


@receiver(user_logged_in, dispatch_uid='audit_successful_login')
def log_successful_login(sender, request, user, **kwargs):
    log_action(
        user=user,
        action='LOGIN',
        model_name='users.User',
        object_id=user.pk,
        object_repr=str(user),
        request=request,
    )


@receiver(user_logged_out, dispatch_uid='audit_successful_logout')
def log_successful_logout(sender, request, user, **kwargs):
    if not user:
        return
    log_action(
        user=user,
        action='LOGOUT',
        model_name='users.User',
        object_id=user.pk,
        object_repr=str(user),
        request=request,
    )

@receiver(post_save, sender=Order)
def log_order_change(sender, instance, created, **kwargs):
    action = 'CREATE' if created else 'UPDATE'
    log_action(
        user=getattr(instance, '_current_user', None),  # set in view
        action=action,
        model_name='orders.Order',
        object_id=instance.id,
        object_repr=str(instance),
        changes={},  # optionally compute diff
        request=None,
        commit=True
    )

@receiver(post_delete, sender=Order)
def log_order_delete(sender, instance, **kwargs):
    log_action(
        user=getattr(instance, '_current_user', None),
        action='DELETE',
        model_name='orders.Order',
        object_id=instance.id,
        object_repr=str(instance),
        changes={},
        request=None,
        commit=True
    )


@receiver(user_login_failed, dispatch_uid='audit_failed_login_security_event')
def log_failed_login(sender, credentials, request=None, **kwargs):
    log_security_event(
        event_type='authentication_failed',
        description='An authentication attempt failed.',
        severity='medium',
        request=request,
    )