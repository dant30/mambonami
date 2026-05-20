# backend/django_admin/apps/analytics/services/aggregator.py
from datetime import date, datetime, timedelta
from decimal import Decimal
import logging
from django.db import transaction
from django.db.models import Sum, Count, Q
from django.utils.timezone import make_aware
from apps.orders.models import Order
from apps.users.models import User
from apps.payouts.models import Payout
from apps.disputes.models import Dispute
from apps.paybill.models import PayBillTransaction
from ..models import DailyMetric

logger = logging.getLogger(__name__)

def aggregate_for_date(target_date: date) -> DailyMetric:
    """Compute all metrics for a single day and store/update the record."""
    start = make_aware(datetime.combine(target_date, datetime.min.time()))
    end = make_aware(datetime.combine(target_date, datetime.max.time()))

    # Use atomic + select_for_update to prevent race conditions
    with transaction.atomic():
        # Lock the metric row if it exists, or create a dummy lock
        metric, created = DailyMetric.objects.select_for_update().get_or_create(date=target_date)

        # Orders
        orders = Order.objects.filter(created_at__range=(start, end))
        total_orders = orders.count()
        completed_orders = orders.filter(status='delivered').count()
        cancelled_orders = orders.filter(status='cancelled').count()

        # Revenue
        total_sales = orders.aggregate(total=Sum('total_amount'))['total'] or Decimal('0')
        platform_commission = orders.aggregate(total=Sum('platform_commission'))['total'] or Decimal('0')
        delivery_fees = orders.aggregate(total=Sum('delivery_fee'))['total'] or Decimal('0')

        # Payouts (completed only)
        farmer_payouts = Payout.objects.filter(
            recipient_type='farmer',
            status='completed',
            created_at__range=(start, end)
        ).aggregate(total=Sum('amount'))['total'] or Decimal('0')

        transport_payouts = Payout.objects.filter(
            recipient_type='transport_provider',
            status='completed',
            created_at__range=(start, end)
        ).aggregate(total=Sum('amount'))['total'] or Decimal('0')

        total_payouts = farmer_payouts + transport_payouts

        # Escrow balance at end of day – use last transaction with running_balance
        last_txn = PayBillTransaction.objects.filter(
            created_at__lte=end
        ).order_by('-created_at').first()
        escrow_balance = last_txn.running_balance if last_txn and hasattr(last_txn, 'running_balance') else Decimal('0')

        # Collections (incoming payments)
        collections_qs = PayBillTransaction.objects.filter(transaction_time__range=(start, end))
        total_collections_amount = collections_qs.aggregate(total=Sum('amount'))['total'] or Decimal('0')
        collections_count = collections_qs.count()
        matched_collections = collections_qs.filter(status='matched').count()
        orphaned_collections = collections_qs.filter(status='orphaned').count()

        # Payouts count & failures
        payouts_qs = Payout.objects.filter(paid_at__range=(start, end))
        payouts_count = payouts_qs.count()
        failed_payouts = payouts_qs.filter(status='failed').count()

        # New users
        new_farmers = User.objects.filter(
            role='farmer',
            date_joined__range=(start, end)
        ).count()
        new_buyers = User.objects.filter(
            role__in=['buyer', 'retailer'],
            date_joined__range=(start, end)
        ).count()
        new_transport = User.objects.filter(
            role='transport_provider',
            date_joined__range=(start, end)
        ).count()

        # Disputes
        disputes_opened = Dispute.objects.filter(created_at__range=(start, end)).count()
        disputes_resolved = Dispute.objects.filter(
            status='resolved',
            resolved_at__range=(start, end)
        ).count()
        disputes_escalated = Dispute.objects.filter(
            status='escalated',
            created_at__range=(start, end)
        ).count()
        disputed_orders = Dispute.objects.filter(
            created_at__range=(start, end)
        ).values('order').distinct().count()

        # Update the metric
        metric.total_orders = total_orders
        metric.completed_orders = completed_orders
        metric.cancelled_orders = cancelled_orders
        metric.disputed_orders = disputed_orders
        metric.total_sales = total_sales
        metric.platform_commission = platform_commission
        metric.delivery_fees_collected = delivery_fees
        metric.total_paid_to_farmers = farmer_payouts
        metric.total_paid_to_transport = transport_payouts
        metric.escrow_balance_at_end = escrow_balance
        metric.total_collections_amount = total_collections_amount
        metric.collections_count = collections_count
        metric.matched_collections = matched_collections
        metric.orphaned_collections = orphaned_collections
        metric.total_payouts_amount = total_payouts
        metric.payouts_count = payouts_count
        metric.failed_payouts = failed_payouts
        metric.new_farmers = new_farmers
        metric.new_buyers = new_buyers
        metric.new_transport_providers = new_transport
        metric.disputes_opened = disputes_opened
        metric.disputes_resolved = disputes_resolved
        metric.disputes_escalated = disputes_escalated
        metric.save(update_fields=[
            'total_orders',
            'completed_orders',
            'cancelled_orders',
            'disputed_orders',
            'total_sales',
            'platform_commission',
            'delivery_fees_collected',
            'total_paid_to_farmers',
            'total_paid_to_transport',
            'escrow_balance_at_end',
            'total_collections_amount',
            'collections_count',
            'matched_collections',
            'orphaned_collections',
            'total_payouts_amount',
            'payouts_count',
            'failed_payouts',
            'new_farmers',
            'new_buyers',
            'new_transport_providers',
            'disputes_opened',
            'disputes_resolved',
            'disputes_escalated',
        ])

        logger.info(f"Aggregated metrics for {target_date}: {metric.id}")
        return metric

def aggregate_range(start_date: date, end_date: date):
    """Aggregate for a range of dates (call from task)."""
    current = start_date
    while current <= end_date:
        aggregate_for_date(current)
        current += timedelta(days=1)