# backend/django_admin/apps/analytics/models/metric.py
from django.db import models
from shared.db_models.base import BaseModel

class DailyMetric(BaseModel):
    """Precomputed daily KPIs for a given date."""
    date = models.DateField(unique=True, db_index=True)

    # Orders
    total_orders = models.PositiveIntegerField(default=0)
    completed_orders = models.PositiveIntegerField(default=0)
    cancelled_orders = models.PositiveIntegerField(default=0)
    disputed_orders = models.PositiveIntegerField(default=0)

    # Revenue
    total_sales = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    platform_commission = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    delivery_fees_collected = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    # Payouts
    total_paid_to_farmers = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total_paid_to_transport = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    # Escrow
    escrow_balance_at_end = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    # Payments (collections & payouts) - additional analytics
    total_collections_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    collections_count = models.PositiveIntegerField(default=0)
    matched_collections = models.PositiveIntegerField(default=0)
    orphaned_collections = models.PositiveIntegerField(default=0)

    total_payouts_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    payouts_count = models.PositiveIntegerField(default=0)
    failed_payouts = models.PositiveIntegerField(default=0)

    # Users
    new_farmers = models.PositiveIntegerField(default=0)
    new_buyers = models.PositiveIntegerField(default=0)
    new_transport_providers = models.PositiveIntegerField(default=0)

    # Disputes
    disputes_opened = models.PositiveIntegerField(default=0)
    disputes_resolved = models.PositiveIntegerField(default=0)
    disputes_escalated = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = 'daily_metrics'
        ordering = ['-date']

    def __str__(self):
        return f"Metrics for {self.date}"