# backend/django_admin/apps/logistics/signals.py
from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from .models import Trip, TripStatusHistory, TripStatus


@receiver(pre_save, sender=Trip)
def log_status_change(sender, instance, **kwargs):
    """
    Detect status change before saving so we can log it in post_save.
    """
    if instance.pk:
        try:
            old = Trip.objects.get(pk=instance.pk)
            if old.status != instance.status:
                # Attach flags so post_save knows what changed
                instance._status_changed = True
                instance._old_status = old.status
        except Trip.DoesNotExist:
            pass


@receiver(post_save, sender=Trip)
def create_status_history_and_trigger_actions(sender, instance, created, **kwargs):
    """Create a timeline record when a trip is created or changes status."""
    if created:
        TripStatusHistory.objects.create(
            trip=instance,
            status=instance.status,
            location_lat=instance.pickup_lat or instance.current_lat,
            location_lng=instance.pickup_lng or instance.current_lng,
            note="Trip created",
            source='system'
        )
    elif hasattr(instance, '_status_changed') and instance._status_changed:
        TripStatusHistory.objects.create(
            trip=instance,
            status=instance.status,
            location_lat=instance.current_lat or instance.pickup_lat or instance.delivery_lat,
            location_lng=instance.current_lng or instance.pickup_lng or instance.delivery_lng,
            note=f"Status changed from {instance._old_status} to {instance.status}",
            source='system'
        )
