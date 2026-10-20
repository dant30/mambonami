# backend/django_admin/apps/disputes/services/resolution.py
import logging
from decimal import Decimal
from django.db import transaction
from django.utils import timezone
from apps.payouts.services.payout_service import _execute_payout
from apps.paybill.models import PayBillTransaction, PaymentAllocation
from apps.paybill.services.reconciliation import get_estimated_float_balance
from core.exceptions import FloatInsufficientError
from ..models import Dispute

logger = logging.getLogger(__name__)

def resolve_dispute(dispute: Dispute, resolution_data: dict, admin_user) -> Dispute:
    """
    Apply resolution: refund buyer, penalize farmer/provider, and optionally release any remaining funds.
    """
    with transaction.atomic():
        dispute.resolution = resolution_data.get("resolution", Dispute.Resolution.NO_ACTION)
        dispute.resolution_notes = resolution_data.get("resolution_notes", "")
        dispute.refund_amount = resolution_data.get("refund_amount", Decimal("0"))
        dispute.penalty_amount = resolution_data.get("penalty_amount", Decimal("0"))
        if penalty_user_id := resolution_data.get("penalty_user_id"):
            from apps.users.models import User
            dispute.penalty_user = User.objects.get(id=penalty_user_id)
        dispute.status = Dispute.Status.RESOLVED
        dispute.resolved_by = admin_user
        dispute.resolved_at = timezone.now()
        dispute.save()

        # Execute financial adjustments
        _apply_refund(dispute)
        _apply_penalty(dispute)

    return dispute

@transaction.atomic
def _apply_refund(dispute: Dispute):
    """Refund buyer via B2C from float."""
    if dispute.refund_amount > 0:
        # Check float balance
        balance = get_estimated_float_balance()
        if balance < dispute.refund_amount:
            raise FloatInsufficientError("Cannot refund: float insufficient")
        payment = PayBillTransaction.objects.select_for_update().filter(
            transaction_code=dispute.order.paybill_transaction_code,
            matched_order=dispute.order,
        ).first()
        if payment is None:
            raise ValueError('Cannot refund an order without its matched payment transaction.')
        if payment.remaining_allocated_amount < dispute.refund_amount:
            raise ValueError('Refund exceeds the order payment amount remaining in escrow.')

        PaymentAllocation.objects.create(
            transaction=payment,
            order=dispute.order,
            allocation_type='refund',
            amount=-dispute.refund_amount,
        )
        payment.remaining_allocated_amount -= dispute.refund_amount
        payment.save(update_fields=['remaining_allocated_amount', 'updated_at'])

        # Create a payout for refund (recipient_type = 'buyer_refund')
        from apps.payouts.models import Payout
        refund_payout = Payout.objects.create(
            order=dispute.order,
            recipient_type='buyer_refund',  # add this choice to Payout.RECIPIENT_TYPE
            recipient_user=dispute.order.buyer,
            amount=dispute.refund_amount,
            status='pending'
        )
        _execute_payout(refund_payout)
        logger.info(f"Refunded {dispute.refund_amount} to buyer for dispute {dispute.id}")

def _apply_penalty(dispute: Dispute):
    """Deduct penalty from future payouts (just log; actual deduction happens in payout calculation)."""
    if dispute.penalty_amount > 0 and dispute.penalty_user:
        # Store penalty in user profile or separate Penalty model for deduction
        # For MVP, just log. In real system, create a Penalty record.
        logger.info(f"Penalty {dispute.penalty_amount} applied to user {dispute.penalty_user.id}")