# backend/django_admin/apps/orders/signals.py
from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from .models import Order
import logging

logger = logging.getLogger(__name__)

@receiver(pre_save, sender=Order)
def generate_account_number(sender, instance, **kwargs):
    if not instance.account_number and instance.id:
        instance.account_number = f"ORD-{instance.id}"

@receiver(post_save, sender=Order)
def log_order_status_change(sender, instance, created, **kwargs):
    if created:
        logger.info(f"Order {instance.id} created by buyer {instance.buyer.phone}")
    else:
        # Track status change if updated
        if hasattr(instance, '_previous_status'):
            if instance._previous_status != instance.status:
                logger.info(f"Order {instance.id} status changed from {instance._previous_status} to {instance.status}")