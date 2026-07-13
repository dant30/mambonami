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
    """
    orphaned = PayBillTransaction.objects.filter(status='orphaned')
    for txn in orphaned:
        if txn.account_number.startswith('ORD-'):
            try:
                order_id = int(txn.account_number.split('-')[1])
                order = Order.objects.filter(id=order_id).first()
                if order:
                    txn.matched_order = order
                    txn.status = 'matched'
                    txn.save(update_fields=['matched_order', 'status'])
                    logger.info(f"Re-matched transaction {txn.transaction_code} to order {order.id}")
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