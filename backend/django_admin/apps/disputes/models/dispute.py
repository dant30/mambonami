# backend/django_admin/apps/disputes/models/dispute.py
from django.conf import settings
from django.db import models
from django.utils import timezone

from shared.db_models.base import BaseModel


# ============================================================================
# DISPUTE
# ============================================================================

class Dispute(BaseModel):

    class Reason(models.TextChoices):
        NOT_FRESH = "not_fresh", "Goods not fresh"
        WRONG_QUANTITY = "wrong_quantity", "Incorrect quantity"
        WRONG_ITEM = "wrong_item", "Wrong product delivered"
        DELIVERY_NOT_RECEIVED = "delivery_not_received", "Delivery never arrived"
        DAMAGED = "damaged", "Goods damaged"
        POOR_QUALITY = "poor_quality", "Poor quality"
        LATE_DELIVERY = "late_delivery", "Late delivery"
        PAYMENT = "payment", "Payment issue"
        OTHER = "other", "Other"

    class Status(models.TextChoices):
        OPEN = "open", "Open"
        UNDER_REVIEW = "under_review", "Under Review"
        WAITING_CUSTOMER = "waiting_customer", "Waiting for Customer"
        WAITING_FARMER = "waiting_farmer", "Waiting for Farmer"
        WAITING_PROVIDER = "waiting_provider", "Waiting for Transport Provider"
        ESCALATED = "escalated", "Escalated"
        RESOLVED = "resolved", "Resolved"
        REJECTED = "rejected", "Rejected"
        CLOSED = "closed", "Closed"

    class Priority(models.TextChoices):
        LOW = "low", "Low"
        MEDIUM = "medium", "Medium"
        HIGH = "high", "High"
        URGENT = "urgent", "Urgent"

    class Resolution(models.TextChoices):
        FULL_REFUND = "full_refund", "Full Refund"
        PARTIAL_REFUND = "partial_refund", "Partial Refund"
        REPLACEMENT = "replacement", "Replacement"
        STORE_CREDIT = "store_credit", "Store Credit"
        COMPENSATE_FARMER = "compensate_farmer", "Compensate Farmer"
        COMPENSATE_PROVIDER = "compensate_provider", "Compensate Provider"
        NO_ACTION = "no_action", "No Action"

    order = models.ForeignKey(
        "orders.Order",
        on_delete=models.CASCADE,
        related_name="disputes",
    )

    raised_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="raised_disputes",
    )

    assigned_to = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="assigned_disputes",
        help_text="Admin currently handling this dispute",
    )

    reason = models.CharField(
        max_length=40,
        choices=Reason.choices,
        db_index=True,
    )

    description = models.TextField()

    evidence = models.JSONField(
        default=list,
        blank=True,
        help_text="Images, videos, receipts or other uploaded evidence",
    )

    status = models.CharField(
        max_length=30,
        choices=Status.choices,
        default=Status.OPEN,
        db_index=True,
    )

    priority = models.CharField(
        max_length=20,
        choices=Priority.choices,
        default=Priority.MEDIUM,
        db_index=True,
    )

    resolution = models.CharField(
        max_length=40,
        choices=Resolution.choices,
        blank=True,
        null=True,
    )

    resolution_notes = models.TextField(blank=True)

    internal_notes = models.TextField(
        blank=True,
        help_text="Visible only to administrators",
    )

    escalation_reason = models.TextField(blank=True)

    refund_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
    )

    penalty_amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0,
    )

    penalty_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="dispute_penalties",
    )

    resolved_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="resolved_disputes",
    )

    resolved_at = models.DateTimeField(
        null=True,
        blank=True,
    )

    closed_at = models.DateTimeField(
        null=True,
        blank=True,
    )

    class Meta:
        db_table = "disputes"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["status"]),
            models.Index(fields=["priority"]),
            models.Index(fields=["reason"]),
            models.Index(fields=["order"]),
            models.Index(fields=["raised_by"]),
            models.Index(fields=["created_at"]),
        ]

    def __str__(self):
        return f"Dispute #{self.pk} ({self.status})"

    def resolve(self, admin, resolution, notes=""):
        self.status = self.Status.RESOLVED
        self.resolution = resolution
        self.resolution_notes = notes
        self.resolved_by = admin
        self.resolved_at = timezone.now()
        self.save(update_fields=["status", "resolution", "resolution_notes", "resolved_by", "resolved_at"])

        DisputeEvent.objects.create(
            dispute=self,
            actor=admin,
            event_type=DisputeEvent.EventType.RESOLVED,
            details=notes,
        )

    def close(self):
        self.status = self.Status.CLOSED
        self.closed_at = timezone.now()
        self.save(update_fields=["status", "closed_at"])


# ============================================================================
# DISPUTE TIMELINE
# ============================================================================

class DisputeEvent(BaseModel):

    class EventType(models.TextChoices):
        CREATED = "created", "Created"
        UPDATED = "updated", "Updated"
        COMMENT = "comment", "Comment Added"
        REVIEWED = "reviewed", "Reviewed"
        EVIDENCE = "evidence", "Evidence Uploaded"
        ESCALATED = "escalated", "Escalated"
        RESOLVED = "resolved", "Resolved"
        REJECTED = "rejected", "Rejected"
        CLOSED = "closed", "Closed"

    dispute = models.ForeignKey(
        Dispute,
        on_delete=models.CASCADE,
        related_name="events",
    )

    actor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="dispute_events",
    )

    event_type = models.CharField(
        max_length=30,
        choices=EventType.choices,
        default=EventType.UPDATED,
    )

    details = models.TextField(blank=True)

    metadata = models.JSONField(
        default=dict,
        blank=True,
        help_text="Optional structured data related to the event",
    )

    class Meta:
        db_table = "dispute_events"
        ordering = ["created_at"]
        indexes = [
            models.Index(fields=["dispute"]),
            models.Index(fields=["event_type"]),
            models.Index(fields=["created_at"]),
        ]

    def __str__(self):
        return f"{self.dispute_id} - {self.event_type}"