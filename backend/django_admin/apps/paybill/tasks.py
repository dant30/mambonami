# backend/django_admin/apps/paybill/tasks.py
from celery import shared_task
import logging
from decimal import Decimal
from django.utils import timezone

from apps.paybill.services.reconciliation import reconcile_orphaned_transactions, get_estimated_float_balance
from apps.paybill.models import PayBillSettlement

logger = logging.getLogger(__name__)

@shared_task
def reconcile_orphaned_payments():
    """
    Periodic task to attempt re‑matching of orphaned transactions.
    Also creates settlement records if missing.
    """
    # 1. Reconcile orphans (uses the updated service)
    reconcile_orphaned_transactions()
    logger.info("Orphaned payment reconciliation completed")

    # 2. (Optional) check if yesterday's settlement is missing and create placeholder
    yesterday = timezone.now().date() - timezone.timedelta(days=1)
    settlement, created = PayBillSettlement.objects.get_or_create(
        settlement_date=yesterday,
        defaults={'amount': Decimal('0'), 'status': 'pending'}
    )
    if created:
        logger.info(f"Created placeholder settlement for {yesterday}")

@shared_task
def check_float_balance():
    """
    Monitor PayBill float and alert if below threshold.
    """
    balance = get_estimated_float_balance()
    if balance < Decimal('100000'):  # 100k KES
        logger.critical(f"PayBill float balance is low: {balance} KES")
        # TODO: Send admin alert via email/Slack
    return balance