# backend/django_admin/apps/analytics/tasks.py
from celery import shared_task
from datetime import date, timedelta
import logging
from .services.aggregator import aggregate_for_date, aggregate_range

logger = logging.getLogger(__name__)

@shared_task(bind=True, max_retries=3, default_retry_delay=300)
def aggregate_today_metrics(self):
    """Run daily aggregation for today (should be scheduled at midnight)."""
    try:
        aggregate_for_date(date.today())
        logger.info("Daily aggregation completed")
        return "Daily aggregation completed"
    except Exception as exc:
        logger.exception("Daily aggregation failed")
        raise self.retry(exc=exc)

@shared_task
def aggregate_yesterday_metrics():
    """Run aggregation for yesterday (fallback)."""
    yesterday = date.today() - timedelta(days=1)
    aggregate_for_date(yesterday)
    logger.info(f"Aggregated for {yesterday}")
    return f"Aggregated for {yesterday}"

@shared_task
def aggregate_metrics_for_range(start_iso: str, end_iso: str):
    start = date.fromisoformat(start_iso)
    end = date.fromisoformat(end_iso)
    aggregate_range(start, end)
    logger.info(f"Aggregated {start} to {end}")
    return f"Aggregated {start} to {end}"

@shared_task
def backfill_metrics():
    """Backfill metrics for all days with orders."""
    from apps.orders.models import Order
    first_order = Order.objects.order_by('created_at').first()
    if first_order:
        start = first_order.created_at.date()
        end = date.today()
        aggregate_range(start, end)
        logger.info(f"Backfilled {start} to {end}")
        return f"Backfilled {start} to {end}"
    logger.info("No orders found for backfill")
    return "No orders found"
