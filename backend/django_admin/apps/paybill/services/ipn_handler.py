# backend/django_admin/apps/paybill/services/ipn_handler.py
"""
M-Pesa PayBill IPN handler – production hardened.
Implements full idempotency, reconciliation, auditing, and payment lifecycle.
"""
import logging
from decimal import Decimal, InvalidOperation
from datetime import datetime
from django.db import transaction, IntegrityError
from django.db.models import F
from django.utils.timezone import make_aware, now
from django.core.exceptions import ObjectDoesNotExist

from apps.paybill.models import (
    MpesaCallback,
    PayBillTransaction,
    AccountNumberReservation,
    PaymentAllocation,
    FloatAdjustment,
)
from apps.orders.models import Order
from apps.analytics.models import DailyMetric

logger = logging.getLogger(__name__)

class IPNHandler:
    """
    Processes M-Pesa PayBill IPN callbacks with full idempotency,
    audit trail, and reconciliation support.
    """

    @classmethod
    def process_callback(cls, callback_data: dict) -> dict:
        """
        Main entry point for the IPN endpoint.

        Args:
            callback_data: Raw JSON payload from Safaricom.

        Returns:
            dict: {'success': bool, 'message': str, 'order_id': int|None}
        """
        # 1. Normalize payload (handle different field names)
        normalized = cls._normalize_payload(callback_data)

        transaction_code = normalized.get('transaction_code')
        if not transaction_code:
            return {'success': False, 'message': 'Missing TransactionCode'}

        # 2. Start atomic transaction with row lock on callback
        with transaction.atomic():
            # Lock the callback record to prevent concurrent processing
            try:
                callback = MpesaCallback.objects.select_for_update().get(
                    pk=transaction_code
                )
                if callback.is_processed:
                    logger.info(f"Callback {transaction_code} already processed, ignoring.")
                    return {'success': True, 'message': 'Already processed'}
            except ObjectDoesNotExist:
                # Create new callback record (locked implicitly)
                callback = MpesaCallback(
                    transaction_code=transaction_code,
                    order_id=None,  # will set later
                    callback_payload=callback_data,
                    is_processed=False,
                    processing_attempts=0,
                )
                callback.save()

            # Increment attempt count for existing callbacks only
            if callback._state.adding:
                callback.save()  # save to get pk, but we'll set order_id later
            else:
                callback.processing_attempts = F('processing_attempts') + 1
                callback.save(update_fields=['processing_attempts'])
                # Refresh the value to get the actual integer
                callback.refresh_from_db(fields=['processing_attempts'])

            # 4. Extract payment fields and validate account number against reservation
            try:
                amount = Decimal(str(normalized.get('amount', '0')))
                account_number = normalized.get('account_number', '')
                sender_phone = normalized.get('sender_phone', '')
                trans_time = normalized.get('trans_time')
                first_name = normalized.get('first_name', '')
                middle_name = normalized.get('middle_name', '')
                last_name = normalized.get('last_name', '')
                business_shortcode = normalized.get('business_shortcode', '')
                transaction_type = str(normalized.get('transaction_type', '') or '')[:20]
            except (InvalidOperation, ValueError, TypeError) as e:
                logger.exception("Error extracting payment fields")
                return {'success': False, 'message': 'Invalid payment data'}

            if amount <= 0 or not account_number:
                return {'success': False, 'message': 'Invalid amount or account number'}

            reservation = AccountNumberReservation.objects.filter(
                account_number=account_number,
                is_used=False,
            ).select_for_update().first()
            if not reservation:
                logger.warning(f"Unrecognized account number: {account_number}")
                # Still proceed as orphaned, but log for manual reconciliation
                order = None
                order_id = None
            else:
                deposit_profile = None
                # Try to resolve order from reservation (if it's an order type)
                if reservation.prefix == 'ORD':
                    order_id = reservation.related_object_id
                    try:
                        order = Order.objects.select_for_update().get(
                            pk=order_id,
                            status='placed'  # only pending orders can be paid
                        )
                    except Order.DoesNotExist:
                        order = None
                        order_id = None
                elif reservation.prefix == 'DEP':
                    from apps.users.models import TransportProviderProfile
                    deposit_profile = TransportProviderProfile.objects.select_for_update().filter(
                        id=reservation.related_object_id,
                    ).first()
                    order = None
                    order_id = None
                else:
                    order = None
                    order_id = None

            if not reservation:
                deposit_profile = None

            # 5. Create or get PayBillTransaction (safely handle duplicates)
            txn_defaults = {
                'amount': amount,
                'account_number': account_number,
                'sender_phone': sender_phone,
                'transaction_time': cls._parse_mpesa_time(trans_time),
                'payer_first_name': first_name,
                'payer_middle_name': middle_name,
                'payer_last_name': last_name,
                'business_shortcode': business_shortcode,
                'transaction_type': transaction_type,
                'currency': 'KES',
                'status': 'received',  # initial status
                'matched_order': order,
                'callback': callback,
                'running_balance': Decimal('0'),  # will update after balance
                'notes': '',
            }
            paybill_txn, txn_created = PayBillTransaction.objects.get_or_create(
                transaction_code=transaction_code,
                defaults=txn_defaults,
            )
            # If the transaction already existed, we might need to refresh it
            if not txn_created:
                # It could have been partially created; we'll continue processing
                logger.info(f"Transaction {transaction_code} already exists, re-processing.")
                # Update the existing transaction with latest data (if needed)
                paybill_txn.sender_phone = sender_phone
                paybill_txn.payer_first_name = first_name
                paybill_txn.payer_middle_name = middle_name
                paybill_txn.payer_last_name = last_name
                paybill_txn.business_shortcode = business_shortcode
                paybill_txn.transaction_type = transaction_type
                paybill_txn.transaction_time = cls._parse_mpesa_time(trans_time)
                # Don't overwrite matched_order if already set
                if not paybill_txn.matched_order and order:
                    paybill_txn.matched_order = order
                paybill_txn.save(update_fields=[
                    'sender_phone', 'payer_first_name', 'payer_middle_name',
                    'payer_last_name', 'business_shortcode', 'transaction_type',
                    'transaction_time', 'matched_order'
                ])

            # 6. Update order status and create allocation if order found
            if order:
                # Mark order as paid (escrow held)
                order.status = 'paid_escrow'
                order.paybill_transaction_code = transaction_code
                order.paid_at = now()
                order.save(update_fields=['status', 'paybill_transaction_code', 'paid_at'])
                logger.info(f"Order {order.id} marked as PAID via IPN")

                # Update transaction status to 'matched'
                paybill_txn.status = 'matched'
                paybill_txn.matched_order = order
                paybill_txn.save(update_fields=['status', 'matched_order'])

                # Create PaymentAllocation
                PaymentAllocation.objects.create(
                    transaction=paybill_txn,
                    order=order,
                    amount=amount,
                    allocation_type='order',
                )
                logger.info(f"Allocation created for order {order.id}")

                # Update AccountNumberReservation to used
                if reservation and not reservation.is_used:
                    reservation.is_used = True
                    reservation.used_at = now()
                    reservation.save(update_fields=['is_used', 'used_at'])

            elif deposit_profile:
                deposit_profile.deposit_paid = True
                deposit_profile.deposit_transaction_id = transaction_code
                deposit_profile.save(update_fields=['deposit_paid', 'deposit_transaction_id'])
                paybill_txn.status = 'matched'
                paybill_txn.notes = f'Transport provider deposit received for profile {deposit_profile.id}'
                paybill_txn.save(update_fields=['status', 'notes'])
                reservation.is_used = True
                reservation.used_at = now()
                reservation.save(update_fields=['is_used', 'used_at'])
                logger.info(f'Transport provider deposit confirmed for profile {deposit_profile.id}')

            else:
                # Orphaned transaction – keep status as 'orphaned'
                paybill_txn.status = 'orphaned'
                paybill_txn.notes = f"No valid order found for account {account_number}"
                paybill_txn.save(update_fields=['status', 'notes'])

            # 7. Update float balance and create FloatAdjustment
            # Get the last running balance (with row lock)
            last_txn = PayBillTransaction.objects.select_for_update().order_by('-created_at').first()
            last_balance = last_txn.running_balance if last_txn else Decimal('0')
            new_balance = last_balance + amount

            paybill_txn.running_balance = new_balance
            paybill_txn.save(update_fields=['running_balance'])

            # Create FloatAdjustment for this transaction
            FloatAdjustment.objects.create(
                adjustment_type='topup',
                source='system',
                amount=amount,
                running_balance=new_balance,
                reason='Incoming PayBill collection',
                reference_transaction=transaction_code,
                initiated_by=None,  # system
            )
            logger.info(f"Float adjustment recorded: +{amount}, new balance {new_balance}")

            # 8. Update analytics (DailyMetric) – increment counters
            # Use a separate transaction to avoid locking the metrics table during payment processing
            # but we can do it within the same atomic block (it's okay)
            today = now().date()
            metric, _ = DailyMetric.objects.get_or_create(date=today)
            metric.total_collections_amount += amount
            metric.collections_count += 1
            if order:
                metric.matched_collections += 1
            else:
                metric.orphaned_collections += 1
            metric.save(update_fields=[
                'total_collections_amount',
                'collections_count',
                'matched_collections',
                'orphaned_collections',
            ])

            # 9. Update callback status to processed
            callback.order_id = order.id if order else None
            callback.is_processed = True
            callback.processed_at = now()
            callback.save(update_fields=['order_id', 'is_processed', 'processed_at'])

            # 10. Send notification to buyer (async)
            if order:
                from apps.notifications.models import Notification

                notif = Notification.objects.create(
                    user=order.buyer,
                    channel='in_app',
                    category='payment',
                    title='Payment Received',
                    body=f"Your payment of KES {amount} for Order #{order.id} has been received.",
                    metadata={
                        'order_id': order.id,
                        'amount': str(amount),
                    }
                )
                try:
                    from apps.notifications.tasks import send_notification_task
                    send_notification_task.delay(notif.id)
                except Exception as exc:
                    logger.warning(f"Notification dispatch skipped: {exc}")

        # End of atomic transaction
        return {
            'success': True,
            'message': 'Callback processed',
            'order_id': order.id if order else None,
        }

    @staticmethod
    def _normalize_payload(data: dict) -> dict:
        """Normalize Safaricom payload field names."""
        normalized = {}
        # Map common field variations
        field_mapping = {
            'TransactionCode': 'transaction_code',
            'Amount': 'amount',
            'TransAmount': 'amount',  # alternative
            'AccountNumber': 'account_number',
            'BillRefNumber': 'account_number',  # sometimes used
            'PhoneNumber': 'sender_phone',
            'MSISDN': 'sender_phone',
            'Time': 'trans_time',
            'TransactionTime': 'trans_time',
            'FirstName': 'first_name',
            'MiddleName': 'middle_name',
            'LastName': 'last_name',
            'BusinessShortCode': 'business_shortcode',
            'TransactionType': 'transaction_type',
        }
        for key, value in data.items():
            if key in field_mapping:
                normalized[field_mapping[key]] = value
            else:
                normalized[key] = value
        return normalized

    @staticmethod
    def _parse_mpesa_time(time_str: str):
        """Convert Safaricom timestamp to timezone-aware datetime."""
        if not time_str:
            return now()
        try:
            # Try the standard format: YYYYMMDDHHMMSS
            naive = datetime.strptime(str(time_str), '%Y%m%d%H%M%S')
            return make_aware(naive)
        except (TypeError, ValueError):
            # Fallback: try parsing ISO format
            try:
                return make_aware(datetime.fromisoformat(str(time_str)))
            except (TypeError, ValueError):
                return now()