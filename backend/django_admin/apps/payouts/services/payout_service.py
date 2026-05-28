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
    Releases funds to farmer(s) and transport provider.
    
    Payment breakdown:
    - Farmer gets: product subtotal - platform commission (8%)
    - Transport provider gets: (agreed_fee + waiting_surcharge) * 80%
    - Platform keeps: product platform commission + transport provider 20% commission
    """
    from apps.orders.models import Order
    from apps.users.models import FarmerProfile, TransportProviderProfile

    order = Order.objects.select_related('trip', 'trip__provider').get(id=order_id)
    if order.status != 'delivered':   # should be set after OTP verification
        logger.warning(f"Order {order_id} not delivered, cannot release payment")
        return

    # Check float balance (optional: can be skipped if we trust float)
    balance = get_estimated_float_balance()
    
    # Calculate total payout needed
    farmer_payouts_total = Decimal('0')
    provider_payout_amount = Decimal('0')
    
    # Calculate farmer payouts (from each sub_order)
    for sub_order in order.sub_orders.all():
        farmer_amount = sub_order.subtotal * (Decimal('1') - Decimal('0.08'))  # 8% commission
        farmer_payouts_total += farmer_amount
    
    # Calculate transport provider payout
    trip = order.trip
    if trip and trip.provider:
        # Total delivery fee = agreed fee + waiting surcharge
        total_trip_fee = trip.agreed_fee + trip.waiting_surcharge
        provider_payout_amount = total_trip_fee * Decimal('0.80')  # Provider gets 80%
    
    total_payout = farmer_payouts_total + provider_payout_amount
    
    if balance < total_payout:
        logger.critical(
            f"Low float balance for order {order_id}: {balance} < {total_payout}"
        )
        raise FloatInsufficientError("PayBill float insufficient for payout")

    # 1. Payout to each farmer
    for sub_order in order.sub_orders.all():
        farmer_profile = sub_order.farmer
        farmer_amount = sub_order.subtotal * (Decimal('1') - Decimal('0.08'))
        if farmer_amount > 0:
            farmer_payout = create_payout(order, farmer_profile.user, farmer_amount, 'farmer')
            _execute_payout(farmer_payout)
            logger.info(
                f"Scheduled payout to farmer {farmer_profile.user.phone}: "
                f"KES {farmer_amount} (sub_order: {sub_order.id})"
            )

    # 2. Payout to transport provider
    if trip and trip.provider and provider_payout_amount > 0:
        provider_payout = create_payout(order, trip.provider.user, provider_payout_amount, 'transport_provider')
        _execute_payout(provider_payout)
        logger.info(
            f"Scheduled payout to provider {trip.provider.user.phone}: "
            f"KES {provider_payout_amount} "
            f"(trip fee: KES {trip.agreed_fee + trip.waiting_surcharge})"
        )


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