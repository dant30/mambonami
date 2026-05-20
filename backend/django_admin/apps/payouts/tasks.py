# backend/django_admin/apps/payouts/tasks.py
from celery import shared_task
from .services.payout_service import release_payment, _execute_payout
from .models import Payout
import logging

logger = logging.getLogger(__name__)

@shared_task(bind=True, max_retries=3)
def release_payment_task(self, order_id):
    """Async wrapper for release_payment."""
    try:
        release_payment(order_id)
    except Exception as e:
        logger.error(f"Release payment task failed for order {order_id}: {e}")
        self.retry(exc=e, countdown=60)

@shared_task
def retry_payout(payout_id):
    """Retry a failed payout."""
    try:
        payout = Payout.objects.get(id=payout_id)
        if payout.status in ('failed', 'retry'):
            _execute_payout(payout)
    except Payout.DoesNotExist:
        pass