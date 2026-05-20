# backend/django_admin/apps/disputes/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Dispute
import logging

logger = logging.getLogger(__name__)

@receiver(post_save, sender=Dispute)
def dispute_created_notification(sender, instance, created, **kwargs):
    if created:
        logger.info(f"New dispute {instance.id} raised for order {instance.order.id}")
        # TODO: send notification to admin via email/WhatsApp