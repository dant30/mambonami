# backend/django_admin/apps/logistics/signals.py
from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from django.utils import timezone
from .models import Trip, TripStatusHistory, TripStatus


@receiver(pre_save, sender=Trip)
def log_status_change(sender, instance, **kwargs):
    """
    Detect status change before saving so we can log it in post_save.
    Also detect if delivery was just completed.
    """
    if instance.pk:
        try:
            old = Trip.objects.get(pk=instance.pk)
            if old.status != instance.status:
                # Attach flags so post_save knows what changed
                instance._status_changed = True
                instance._old_status = old.status
                instance._old_delivered = old.status == TripStatus.DELIVERED
        except Trip.DoesNotExist:
            pass


@receiver(post_save, sender=Trip)
def create_status_history_and_trigger_actions(sender, instance, created, **kwargs):
    """
    1. Create a status history entry whenever a trip is created or its status changes.
    2. If status becomes 'delivered', trigger the payout release (async).
    3. If status becomes 'cancelled' or 'failed', update order status accordingly.
    """
    # ── 1. Log history ──
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

    # ── 2. Trigger payout if delivered ──
    if instance.status == TripStatus.DELIVERED and not getattr(instance, '_old_delivered', False):
        # Ensure the timestamp is set
        if not instance.completed_at:
            instance.completed_at = timezone.now()
            instance.save(update_fields=['completed_at'])
        
        # Update order status
        order = instance.order
        order.status = 'delivered'
        order.delivered_at = instance.completed_at
        order.save(update_fields=['status', 'delivered_at'])
        
        # Update provider metrics
        if instance.provider:
            instance.provider.total_deliveries += 1
            instance.provider.save(update_fields=['total_deliveries'])
            # Schedule reliability update
            from .tasks import update_provider_reliability_metrics
            update_provider_reliability_metrics.delay(instance.provider.id)
        
        # Trigger payout asynchronously
        from apps.payouts.services.payout_service import release_payment
        release_payment.delay(instance.order.id)

    # ── 3. Handle cancellation/failure ──
    elif instance.status in [TripStatus.CANCELLED, TripStatus.FAILED]:
        if not instance.cancelled_at and instance.status == TripStatus.CANCELLED:
            instance.cancelled_at = timezone.now()
            instance.save(update_fields=['cancelled_at'])
        elif not instance.failed_at and instance.status == TripStatus.FAILED:
            instance.failed_at = timezone.now()
            instance.save(update_fields=['failed_at'])
        
        # Update order status
        order = instance.order
        if order.status not in ['delivered', 'cancelled']:
            order.status = 'cancelled' if instance.status == TripStatus.CANCELLED else 'failed'
            order.save(update_fields=['status'])