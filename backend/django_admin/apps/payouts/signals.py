# backend/django_admin/apps/payouts/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from apps.logistics.models import Trip
from .services.payout_service import release_payment

@receiver(post_save, sender=Trip)
def trip_delivered_handler(sender, instance, created, **kwargs):
    """When a trip status becomes 'delivered', trigger payout."""
    if instance.status == 'delivered' and not created:
        # Use async task to avoid blocking
        from .tasks import release_payment_task
        release_payment_task.delay(instance.order.id)