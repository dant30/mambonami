from django.conf import settings
from django.db import models

from shared.db_models.base import BaseModel


# =============================================================================
# DAILY PLATFORM METRICS
# =============================================================================

class DailyMetric(BaseModel):
    """
    Precomputed daily platform KPIs.
    Populated by scheduled jobs every night.
    """

    date = models.DateField(
        unique=True,
        db_index=True,
    )

    # =========================================================================
    # ORDERS
    # =========================================================================

    total_orders = models.PositiveIntegerField(default=0)
    completed_orders = models.PositiveIntegerField(default=0)
    cancelled_orders = models.PositiveIntegerField(default=0)
    disputed_orders = models.PositiveIntegerField(default=0)

    # =========================================================================
    # REVENUE
    # =========================================================================

    total_sales = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
    )

    platform_commission = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
    )

    delivery_fees_collected = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
    )

    # =========================================================================
    # PAYOUTS
    # =========================================================================

    total_paid_to_farmers = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
    )

    total_paid_to_transport = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
    )

    # =========================================================================
    # ESCROW
    # =========================================================================

    escrow_balance_at_end = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
    )

    # =========================================================================
    # COLLECTIONS
    # =========================================================================

    total_collections_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
    )

    collections_count = models.PositiveIntegerField(default=0)
    matched_collections = models.PositiveIntegerField(default=0)
    orphaned_collections = models.PositiveIntegerField(default=0)

    # =========================================================================
    # PAYOUTS ANALYTICS
    # =========================================================================

    total_payouts_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
    )

    payouts_count = models.PositiveIntegerField(default=0)
    failed_payouts = models.PositiveIntegerField(default=0)

    # =========================================================================
    # USERS
    # =========================================================================

    new_farmers = models.PositiveIntegerField(default=0)
    new_buyers = models.PositiveIntegerField(default=0)
    new_transport_providers = models.PositiveIntegerField(default=0)

    # =========================================================================
    # DISPUTES
    # =========================================================================

    disputes_opened = models.PositiveIntegerField(default=0)
    disputes_resolved = models.PositiveIntegerField(default=0)
    disputes_escalated = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = "daily_metrics"
        ordering = ["-date"]
        indexes = [
            models.Index(fields=["date"]),
        ]

    def __str__(self):
        return f"Daily Metrics ({self.date})"


# =============================================================================
# ANALYTICS EXPORT JOBS
# =============================================================================

class AnalyticsExportJob(BaseModel):
    """
    Background export jobs for reports.
    Processed asynchronously (Celery/RQ).
    """

    class ExportFormat(models.TextChoices):
        CSV = "csv", "CSV"
        XLSX = "xlsx", "Excel"
        PDF = "pdf", "PDF"
        JSON = "json", "JSON"

    class Status(models.TextChoices):
        QUEUED = "queued", "Queued"
        PROCESSING = "processing", "Processing"
        COMPLETED = "completed", "Completed"
        FAILED = "failed", "Failed"
        CANCELLED = "cancelled", "Cancelled"

    requested_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="analytics_exports",
    )

    export_format = models.CharField(
        max_length=10,
        choices=ExportFormat.choices,
        default=ExportFormat.CSV,
    )

    filters = models.JSONField(
        default=dict,
        blank=True,
        help_text="Applied export filters.",
    )

    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.QUEUED,
        db_index=True,
    )

    file_path = models.CharField(
        max_length=500,
        blank=True,
        help_text="Generated file storage path.",
    )

    file_size = models.PositiveBigIntegerField(
        default=0,
        help_text="Generated file size in bytes.",
    )

    expires_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text="When the export becomes unavailable.",
    )

    started_at = models.DateTimeField(
        null=True,
        blank=True,
    )

    completed_at = models.DateTimeField(
        null=True,
        blank=True,
    )

    error_message = models.TextField(
        blank=True,
    )

    class Meta:
        db_table = "analytics_export_jobs"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["status"]),
            models.Index(fields=["requested_by"]),
            models.Index(fields=["created_at"]),
        ]

    def __str__(self):
        return f"{self.get_export_format_display()} ({self.status})"