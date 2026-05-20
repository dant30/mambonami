# Reconcile payments
# backend/django_admin/apps/paybill/services/reconciliation.py
import logging
from decimal import Decimal
from django.db.models import Sum
from apps.paybill.models import PayBillTransaction, FloatAdjustment
from apps.paybill.services.ipn_handler import IPNHandler
from apps.orders.models import Order

logger = logging.getLogger(__name__)

def get_estimated_float_balance() -> Decimal:
    """
    Calculate the current estimated PayBill float balance based on
    matched incoming transactions minus completed payouts.
    This is a fallback; the real balance should be fetched from Safaricom.
    """
    total_collected = PayBillTransaction.objects.filter(status='matched').aggregate(
        total=Sum('amount')
    )['total'] or Decimal('0')

    paid_out = Decimal('0')
    try:
        from apps.payouts.models import Payout
        paid_out = Payout.objects.filter(status='completed').aggregate(
            total=Sum('amount')
        )['total'] or Decimal('0')
    except (ImportError, Exception):
        logger.debug('Payout model unavailable; float balance uses only collected amount')

    return total_collected - paid_out

def reconcile_orphaned_transactions():
    """
    Attempt to re-match orphaned PayBill transactions to orders.
    This can be called by a management command or admin action.
    """
    orphaned = PayBillTransaction.objects.filter(status='orphaned')
    for txn in orphaned:
        # Try to match again (maybe order was created after IPN arrived)
        if txn.account_number.startswith('ORD-'):
            try:
                order_id = int(txn.account_number.split('-')[1])
                if Order.objects.filter(id=order_id).exists():
                    txn.status = 'matched'
                    txn.matched_order_id = order_id
                    txn.save(update_fields=['status', 'matched_order_id'])
                    logger.info(f"Re-matched transaction {txn.transaction_code} to order {order_id}")
            except (IndexError, ValueError):
                continue

def log_float_adjustment(adjustment_type: str, amount: Decimal, reason: str, initiated_by: str, current_balance: Decimal):
    """
    Record a manual adjustment to the PayBill float (e.g., admin top‑up).
    """
    return FloatAdjustment.objects.create(
        adjustment_type=adjustment_type,
        amount=amount,
        running_balance=current_balance,
        reason=reason,
        initiated_by=initiated_by
    )