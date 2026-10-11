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
    from apps.orders.services.state_machine import OrderStateMachine

    payouts_to_execute = []
    with transaction.atomic():
        order = Order.objects.select_for_update().select_related('trip', 'trip__provider__user').get(id=order_id)
        if order.status != 'delivered':
            logger.warning('Order %s is not delivered; payout release skipped', order_id)
            return
        if not OrderStateMachine.has_successful_payment(order):
            raise ValueError(f'Order {order_id} has no reconciled payment allocation.')

        sub_orders = order.sub_orders.select_related('farmer__user').all()
        payout_total = sum((sub_order.farmer_payout for sub_order in sub_orders), Decimal('0'))
        trip = getattr(order, 'trip', None)
        provider_amount = Decimal('0')
        if trip and trip.provider:
            provider_amount = (trip.agreed_fee + trip.waiting_surcharge) * Decimal('0.80')
        total_payout = payout_total + provider_amount
        balance = get_estimated_float_balance()
        if balance < total_payout:
            logger.critical('Low float balance for order %s: %s < %s', order_id, balance, total_payout)
            raise FloatInsufficientError('PayBill float insufficient for payout')

        for sub_order in sub_orders:
            amount = sub_order.farmer_payout
            if amount <= 0:
                continue
            payout, created = Payout.objects.get_or_create(
                order=order,
                recipient_type='farmer',
                recipient_user=sub_order.farmer.user,
                defaults={'amount': amount, 'status': 'pending'},
            )
            if created:
                payouts_to_execute.append(payout)

        if trip and trip.provider and provider_amount > 0:
            payout, created = Payout.objects.get_or_create(
                order=order,
                recipient_type='transport_provider',
                recipient_user=trip.provider.user,
                defaults={'amount': provider_amount, 'status': 'pending'},
            )
            if created:
                payouts_to_execute.append(payout)

    for payout in payouts_to_execute:
        _execute_payout(payout)
        logger.info(
            'Payout %s created for order %s recipient %s amount %s',
            payout.id,
            order_id,
            payout.recipient_user_id,
            payout.amount,
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