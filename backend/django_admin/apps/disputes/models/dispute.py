# backend/django_admin/apps/disputes/models/dispute.py
from django.db import models
from shared.db_models.base import BaseModel
from apps.orders.models import Order
from apps.users.models import User

class Dispute(BaseModel):
    """Represents a user complaint about an order."""
    DISPUTE_REASONS = [
        ('not_fresh', 'Goods not fresh'),
        ('wrong_quantity', 'Incorrect quantity'),
        ('wrong_item', 'Wrong product delivered'),
        ('delivery_never_came', 'Delivery never arrived'),
        ('damaged', 'Goods damaged'),
        ('other', 'Other'),
    ]
    STATUS_CHOICES = [
        ('open', 'Open'),
        ('under_review', 'Under Review'),
        ('resolved', 'Resolved'),
        ('rejected', 'Rejected'),
        ('escalated', 'Escalated'),
    ]
    RESOLUTION_TYPES = [
        ('full_refund', 'Full Refund'),
        ('partial_refund', 'Partial Refund'),
        ('no_refund', 'No Refund'),
        ('compensate_farmer', 'Compensate Farmer'),
        ('compensate_provider', 'Compensate Provider'),
    ]

    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='disputes')
    raised_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='raised_disputes')
    reason = models.CharField(max_length=30, choices=DISPUTE_REASONS)
    description = models.TextField(help_text="Detailed description of the issue")
    evidence_photos = models.JSONField(default=list, help_text="List of photo URLs uploaded by user")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='open', db_index=True)
    resolution_type = models.CharField(max_length=30, choices=RESOLUTION_TYPES, blank=True, null=True)
    resolution_notes = models.TextField(blank=True)
    resolved_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='resolved_disputes')
    resolved_at = models.DateTimeField(null=True, blank=True)
    refund_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    penalty_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    penalty_user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='penalties')

    class Meta:
        db_table = 'disputes'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', 'created_at']),
            models.Index(fields=['order']),
        ]

    def __str__(self):
        return f"Dispute {self.id} - Order {self.order.id} - {self.status}"