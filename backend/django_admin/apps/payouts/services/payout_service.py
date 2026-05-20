# backend/django_admin/apps/payouts/services/payout_service.py
from decimal import Decimal
from django.db import transaction
from django.utils import timezone
from apps.paybill.services.reconciliation import get_estimated_float_balance
from core.exceptions import FloatInsufficientError
from ..models import Payout
from .b2c_client import SafaricomB2CClient
import logging

logger = logging.getLogger(__name__)

def create_payout(order, recipient_user, amount, recipient_type) -> Payout:
    """Create a pending payout record."""
    with transaction.atomic():
        payout = Payout.objects.create(
            order=order,
            recipient_user=recipient_user,
            amount=amount,
            recipient_type=recipient_type,
            status='pending'
        )
        return payout

def release_payment(order_id: int):
    """
    Main entry point: called when delivery is confirmed.
    Releases funds to farmer and transport provider.
    """
    from apps.orders.models import Order
    from apps.users.models import FarmerProfile, TransportProviderProfile

    order = Order.objects.select_related('trip').get(id=order_id)
    if order.status != 'delivered':   # should be set after OTP verification
        logger.warning(f"Order {order_id} not delivered, cannot release payment")
        return

    # Check float balance (optional: can be skipped if we trust float)
    balance = get_estimated_float_balance()
    total_payout = order.total_amount - (order.platform_commission)  # farmer + delivery fee share
    if balance < total_payout:
        logger.critical(f"Low float balance for order {order_id}: {balance} < {total_payout}")
        raise FloatInsufficientError("PayBill float insufficient for payout")

    # 1. Payout to farmer
    farmer_profile = order.farmer_profile
    farmer_amount = order.subtotal - order.platform_commission  # subtotal - 8% (example)
    if farmer_amount > 0:
        farmer_payout = create_payout(order, farmer_profile.user, farmer_amount, 'farmer')
        _execute_payout(farmer_payout)

    # 2. Payout to transport provider
    trip = order.trip
    if trip and trip.provider:
        provider_amount = order.delivery_fee * Decimal('0.8')  # provider gets 80%
        provider_payout = create_payout(order, trip.provider.user, provider_amount, 'transport_provider')
        _execute_payout(provider_payout)

def _execute_payout(payout: Payout):
    """Send B2C request and update payout record."""
    client = SafaricomB2CClient()
    try:
        result = client.send_b2c_payment(
            phone_number=payout.recipient_user.phone,
            amount=float(payout.amount),
            order_id=payout.order.id,
            recipient_type=payout.recipient_type
        )
        payout.b2c_transaction_id = result.get('ConversationID', '')
        payout.status = 'processing'
        payout.save(update_fields=['b2c_transaction_id', 'status'])
        # Note: final success/failure will be updated via callback endpoint
    except Exception as e:
        payout.status = 'failed'
        payout.error_message = str(e)
        payout.save(update_fields=['status', 'error_message'])
        logger.error(f"Payout {payout.id} failed: {e}")

def handle_b2c_callback(data: dict):
    """
    Called from callback endpoint (ResultURL) to update payout status.
    """
    conversation_id = data.get('Result', {}).get('ConversationID')
    result_code = data.get('Result', {}).get('ResultCode')
    if not conversation_id:
        return
    try:
        payout = Payout.objects.get(b2c_transaction_id=conversation_id)
        if result_code == '0':
            payout.status = 'completed'
            payout.paid_at = timezone.now()
        else:
            payout.status = 'failed'
            payout.error_message = data.get('Result', {}).get('ResultDesc', 'Unknown error')
            # Schedule retry if retry_count < 3
            if payout.retry_count < 3:
                payout.status = 'retry'
                payout.retry_count += 1
                from ..tasks import retry_payout
                retry_payout.apply_async((payout.id,), countdown=3600)  # retry after 1 hour
        payout.save(update_fields=['status', 'paid_at', 'error_message', 'retry_count'])
    except Payout.DoesNotExist:
        logger.error(f"Payout not found for conversation {conversation_id}")