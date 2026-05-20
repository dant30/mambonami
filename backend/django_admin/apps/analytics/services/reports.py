# backend/django_admin/apps/analytics/services/reports.py
from datetime import date, timedelta
from decimal import Decimal
from django.db.models import Sum
from ..models import DailyMetric
from apps.orders.models import Order
from apps.users.models import User, FarmerProfile, TransportProviderProfile
from apps.paybill.models import PayBillTransaction
from apps.payouts.models import Payout


def get_summary_report(start_date: date, end_date: date) -> dict:
    """Generate a summary report over a date range using precomputed metrics."""
    metrics = DailyMetric.objects.filter(date__range=(start_date, end_date))
    if not metrics:
        return {}

    agg = metrics.aggregate(
        total_orders=Sum('total_orders'),
        completed_orders=Sum('completed_orders'),
        total_sales=Sum('total_sales'),
        platform_commission=Sum('platform_commission'),
        total_paid_to_farmers=Sum('total_paid_to_farmers'),
        total_paid_to_transport=Sum('total_paid_to_transport'),
    )
    return {
        'start_date': start_date.isoformat(),
        'end_date': end_date.isoformat(),
        'total_orders': agg['total_orders'] or 0,
        'completed_orders': agg['completed_orders'] or 0,
        'total_sales': agg['total_sales'] or Decimal('0'),
        'platform_commission': agg['platform_commission'] or Decimal('0'),
        'total_paid_to_farmers': agg['total_paid_to_farmers'] or Decimal('0'),
        'total_paid_to_transport': agg['total_paid_to_transport'] or Decimal('0'),
    }


def get_top_farmers(limit=10, days=30):
    """Return top farmers by total_sales (from FarmerProfile)."""
    cutoff = date.today() - timedelta(days=days)
    farmers = FarmerProfile.objects.filter(
        user__date_joined__date__gte=cutoff
    ).order_by('-total_sales')[:limit]
    return [
        {
            'id': f.id,
            'user_phone': f.user.phone,
            'total_sales': f.total_sales
        } for f in farmers
    ]


def get_top_transport_providers(limit=10, days=30):
    """Return top transport providers by total_deliveries."""
    cutoff = date.today() - timedelta(days=days)
    providers = TransportProviderProfile.objects.filter(
        user__date_joined__date__gte=cutoff
    ).order_by('-total_deliveries')[:limit]
    return [
        {
            'id': p.id,
            'user_phone': p.user.phone,
            'total_deliveries': p.total_deliveries
        } for p in providers
    ]


def get_payments_metrics(start_date: date, end_date: date) -> dict:
    """Compute payments-related KPIs over a date range.

    Uses PayBillTransaction (collections) and Payout (disbursements).
    Returns totals and counts for collections and payouts.
    """
    # Collections (incoming payments)
    collections_qs = PayBillTransaction.objects.filter(transaction_time__date__range=(start_date, end_date))
    total_collected = collections_qs.aggregate(total=Sum('amount'))['total'] or Decimal('0')
    collections_count = collections_qs.count()
    matched_collections = collections_qs.filter(status='matched').count()
    orphaned_collections = collections_qs.filter(status='orphaned').count()

    # Payouts (outgoing disbursements)
    payouts_qs = Payout.objects.filter(paid_at__date__range=(start_date, end_date))
    total_payouts = payouts_qs.aggregate(total=Sum('amount'))['total'] or Decimal('0')
    payouts_count = payouts_qs.count()
    failed_payouts = Payout.objects.filter(paid_at__date__range=(start_date, end_date), status='failed').count()

    return {
        'start_date': start_date.isoformat(),
        'end_date': end_date.isoformat(),
        'collections': {
            'total_amount': total_collected,
            'count': collections_count,
            'matched_count': matched_collections,
            'orphaned_count': orphaned_collections,
        },
        'payouts': {
            'total_amount': total_payouts,
            'count': payouts_count,
            'failed_count': failed_payouts,
        }
    }