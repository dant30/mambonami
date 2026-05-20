# backend/django_admin/apps/paybill/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from apps.paybill.models import PayBillTransaction
import logging

logger = logging.getLogger(__name__)

@receiver(post_save, sender=PayBillTransaction)
def log_new_transaction(sender, instance, created, **kwargs):
    if created:
        logger.info(f"New PayBill transaction: {instance.transaction_code} | {instance.amount} KES | Account: {instance.account_number}")