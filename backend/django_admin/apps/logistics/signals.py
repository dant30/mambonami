# backend/django_admin/apps/logistics/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Trip

@receiver(post_save, sender=Trip)
def trip_status_changed(sender, instance, created, **kwargs):
    if created:
        # Notify provider via push/WhatsApp
        pass
    if instance.status == 'delivered' and not instance.delivered_at:
        # Trigger payout release
        from apps.payouts.services.payout_service import release_payment
        release_payment.delay(instance.order.id)