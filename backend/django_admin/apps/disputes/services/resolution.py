# backend/django_admin/apps/disputes/services/resolution.py
import logging
from decimal import Decimal
from django.db import transaction
from django.utils import timezone
from apps.payouts.services.payout_service import create_payout, _execute_payout
from apps.paybill.services.reconciliation import get_estimated_float_balance
from core.exceptions import FloatInsufficientError
from ..models import Dispute

logger = logging.getLogger(__name__)

def resolve_dispute(dispute: Dispute, resolution_data: dict, admin_user) -> Dispute:
    """
    Apply resolution: refund buyer, penalize farmer/provider, and optionally release any remaining funds.
    """
    with transaction.atomic():
        dispute.resolution_type = resolution_data['resolution_type']
        dispute.resolution_notes = resolution_data.get('resolution_notes', '')
        dispute.refund_amount = resolution_data.get('refund_amount', Decimal('0'))
        dispute.penalty_amount = resolution_data.get('penalty_amount', Decimal('0'))
        if penalty_user_id := resolution_data.get('penalty_user_id'):
            from apps.users.models import User
            dispute.penalty_user = User.objects.get(id=penalty_user_id)
        dispute.status = 'resolved'
        dispute.resolved_by = admin_user
        dispute.resolved_at = timezone.now()
        dispute.save()

        # Execute financial adjustments
        _apply_refund(dispute)
        _apply_penalty(dispute)

        # If dispute is resolved and order still has escrow, release remaining to farmer/provider
        _release_remaining_escrow(dispute)

    return dispute

def _apply_refund(dispute: Dispute):
    """Refund buyer via B2C from float."""
    if dispute.refund_amount > 0:
        # Check float balance
        balance = get_estimated_float_balance()
        if balance < dispute.refund_amount:
            raise FloatInsufficientError("Cannot refund: float insufficient")
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

def _release_remaining_escrow(dispute: Dispute):
    """If dispute is resolved and order not fully settled, release remaining funds."""
    # Check if order's remaining escrow needs to be released to farmer/provider
    # This depends on your order state machine. For MVP, we can trigger a payout service.
    from apps.payouts.services.payout_service import release_payment
    # Only release if order not already fully paid
    if dispute.order.status != 'delivered':
        release_payment(dispute.order.id)