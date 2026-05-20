# backend/django_admin/apps/paybill/tasks.py
from celery import shared_task
import logging
from decimal import Decimal

from apps.paybill.services.reconciliation import reconcile_orphaned_transactions, get_estimated_float_balance

logger = logging.getLogger(__name__)

@shared_task
def reconcile_orphaned_payments():
    """
    Periodic task to attempt re‑matching of orphaned transactions.
    Schedule every 30 minutes.
    """
    reconcile_orphaned_transactions()
    logger.info("Orphaned payment reconciliation completed")

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