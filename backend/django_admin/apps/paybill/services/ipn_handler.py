# M-Pesa IPN callback handler
# backend/django_admin/apps/paybill/services/ipn_handler.py
import logging
from decimal import Decimal, InvalidOperation
from datetime import datetime
from django.db import IntegrityError, transaction
from django.db.models import F
from django.utils.timezone import make_aware, now
from apps.paybill.models import MpesaCallback, PayBillTransaction
from apps.orders.models import Order  # assuming Order model exists

logger = logging.getLogger(__name__)

class IPNHandler:
    """
    Processes M-Pesa PayBill IPN callbacks.
    Implements idempotency, transaction logging, and order matching.
    """

    @classmethod
    def process_callback(cls, callback_data: dict) -> dict:
        """
        Main entry point for the IPN endpoint.

        Args:
            callback_data: Raw JSON payload from Safaricom (should contain
                           TransactionCode, Amount, AccountNumber, etc.)

        Returns:
            dict: {'success': bool, 'message': str, 'order_id': int|None}
        """
        transaction_code = callback_data.get('TransactionCode')
        if not transaction_code:
            return {'success': False, 'message': 'Missing TransactionCode'}

        # 1. Idempotency check
        if MpesaCallback.objects.filter(pk=transaction_code).exists():
            logger.info(f"Duplicate callback ignored: {transaction_code}")
            return {'success': True, 'message': 'Duplicate callback ignored'}

        # 2. Extract and validate fields
        try:
            amount = Decimal(str(callback_data.get('Amount', '0')))
            account_number = callback_data.get('AccountNumber', '')
            sender_phone = callback_data.get('PhoneNumber', '')
            trans_time = callback_data.get('Time')  # e.g., '20240516120000'
        except (InvalidOperation, ValueError, TypeError):
            return {'success': False, 'message': 'Invalid amount format'}

        if amount <= 0 or not account_number:
            return {'success': False, 'message': 'Invalid amount or account number'}

        # 3. Try to match account number to an order (ORD-{id})
        order_id = None
        if account_number.startswith('ORD-'):
            try:
                order_id = int(account_number.split('-')[1])
            except (IndexError, ValueError):
                pass

        # 4. Create idempotency record and transaction atomically
        with transaction.atomic():
            try:
                MpesaCallback.objects.create(
                    transaction_code=transaction_code,
                    order_id=order_id,
                    callback_payload=callback_data
                )
            except IntegrityError:
                logger.info(f"Duplicate callback ignored: {transaction_code}")
                return {'success': True, 'message': 'Duplicate callback ignored'}

            last_balance = PayBillTransaction.objects.select_for_update().order_by('-created_at').values_list('running_balance', flat=True).first() or Decimal('0')
            running_balance = last_balance + amount

            paybill_txn = PayBillTransaction.objects.create(
                transaction_code=transaction_code,
                amount=amount,
                account_number=account_number,
                sender_phone=sender_phone,
                transaction_time=cls._parse_mpesa_time(trans_time),
                status='matched' if order_id else 'orphaned',
                matched_order_id=order_id,
                running_balance=running_balance,
            )

            if order_id:
                try:
                    order = Order.objects.select_for_update().get(id=order_id)
                    if order.status == 'placed':
                        order.status = 'paid_escrow'
                        order.save(update_fields=['status'])
                        logger.info(f"Order {order_id} marked as PAID via IPN")
                    else:
                        logger.warning(f"Order {order_id} already in status {order.status}")
                except Order.DoesNotExist:
                    paybill_txn.status = 'orphaned'
                    paybill_txn.notes = f"Order {order_id} does not exist"
                    paybill_txn.save(update_fields=['status', 'notes'])
                    logger.error(f"Order {order_id} not found for IPN")
                    order_id = None

        return {
            'success': True,
            'message': 'Callback processed',
            'order_id': order_id
        }

    @staticmethod
    def _parse_mpesa_time(time_str: str):
        """
        Convert Safaricom timestamp 'YYYYMMDDHHMMSS' to timezone-aware datetime.
        Falls back to now() if parsing fails.
        """
        try:
            naive = datetime.strptime(str(time_str), '%Y%m%d%H%M%S')
            return make_aware(naive)
        except (TypeError, ValueError):
            return now()