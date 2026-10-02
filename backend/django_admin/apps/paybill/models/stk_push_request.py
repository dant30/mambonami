from django.db import models

from shared.db_models.base import BaseModel


class StkPushRequest(BaseModel):
    class Status(models.TextChoices):
        INITIATING = 'initiating', 'Initiating'
        PENDING = 'pending', 'Pending'
        SUCCEEDED = 'succeeded', 'Succeeded'
        FAILED = 'failed', 'Failed'

    order = models.ForeignKey(
        'orders.Order',
        on_delete=models.CASCADE,
        related_name='stk_push_requests',
    )
    phone_number = models.CharField(max_length=15)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.INITIATING, db_index=True)
    merchant_request_id = models.CharField(max_length=100, blank=True)
    checkout_request_id = models.CharField(max_length=100, unique=True, null=True, blank=True)
    result_code = models.IntegerField(null=True, blank=True)
    result_description = models.TextField(blank=True)
    callback_payload = models.JSONField(default=dict, blank=True)

    class Meta:
        db_table = 'paybill_stk_push_requests'
        ordering = ['-created_at']
        indexes = [models.Index(fields=['order', 'status'], name='paybill_stk_order_i_772ba7_idx')]
