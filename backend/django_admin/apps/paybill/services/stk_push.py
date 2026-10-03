import base64
import logging
import re
from datetime import timedelta
from decimal import Decimal

import requests
from django.conf import settings
from django.db import transaction
from django.utils import timezone

from apps.orders.models import Order
from apps.paybill.models import StkPushRequest

logger = logging.getLogger(__name__)


class StkPushError(Exception):
    pass


def normalize_ke_phone(value: str) -> str:
    digits = re.sub(r'\D', '', value or '')
    if digits.startswith('0') and len(digits) == 10:
        digits = f'254{digits[1:]}'
    elif digits.startswith('7') or digits.startswith('1'):
        digits = f'254{digits}'
    if not re.fullmatch(r'254[17]\d{8}', digits):
        raise StkPushError('Enter a valid Kenyan M-Pesa number, for example 0712345678.')
    return digits


def _required_setting(name: str) -> str:
    value = str(getattr(settings, name, '') or '').strip()
    if not value:
        raise StkPushError('M-Pesa STK Push is not configured. Use the PayBill details below.')
    return value


def initiate_order_stk_push(order: Order, phone_number: str) -> StkPushRequest:
    if order.status != 'placed':
        raise StkPushError('This order is no longer awaiting payment.')

    phone = normalize_ke_phone(phone_number)
    amount = Decimal(order.total_amount)
    if amount <= 0 or amount != amount.to_integral_value():
        raise StkPushError('STK Push requires an order total in whole Kenyan shillings. Use the PayBill instructions below.')

    existing = StkPushRequest.objects.filter(
        order=order,
        status=StkPushRequest.Status.PENDING,
        created_at__gte=timezone.now() - timedelta(minutes=3),
    ).first()
    if existing:
        raise StkPushError('An M-Pesa prompt is already pending. Check your phone or use the PayBill fallback.')

    consumer_key = _required_setting('MPESA_CONSUMER_KEY')
    consumer_secret = _required_setting('MPESA_CONSUMER_SECRET')
    passkey = _required_setting('MPESA_PASSKEY')
    shortcode = _required_setting('MPESA_PAYBILL_NUMBER')
    base_url = _required_setting('MPESA_ENVIRONMENT_URL').rstrip('/')
    callback_base = _required_setting('CALLBACK_BASE_URL').rstrip('/')

    push_request = StkPushRequest.objects.create(
        order=order,
        phone_number=phone,
        amount=amount,
        status=StkPushRequest.Status.INITIATING,
    )

    try:
        token_response = requests.get(
            f'{base_url}/oauth/v1/generate',
            params={'grant_type': 'client_credentials'},
            auth=(consumer_key, consumer_secret),
            timeout=15,
        )
        token_response.raise_for_status()
        access_token = token_response.json().get('access_token')
        if not access_token:
            raise StkPushError('Safaricom did not return an access token. Use the PayBill fallback.')

        timestamp = timezone.localtime().strftime('%Y%m%d%H%M%S')
        password = base64.b64encode(f'{shortcode}{passkey}{timestamp}'.encode()).decode()
        payload = {
            'BusinessShortCode': shortcode,
            'Password': password,
            'Timestamp': timestamp,
            'TransactionType': 'CustomerPayBillOnline',
            'Amount': int(amount),
            'PartyA': phone,
            'PartyB': shortcode,
            'PhoneNumber': phone,
            'CallBackURL': f'{callback_base}/api/paybill/stk-callback/',
            'AccountReference': order.account_number,
            'TransactionDesc': f'MAMBONAMI order {order.account_number}'[:20],
        }
        response = requests.post(
            f'{base_url}/mpesa/stkpush/v1/processrequest',
            json=payload,
            headers={'Authorization': f'Bearer {access_token}'},
            timeout=20,
        )
        response.raise_for_status()
        result = response.json()
        if str(result.get('ResponseCode')) != '0' or not result.get('CheckoutRequestID'):
            message = result.get('ResponseDescription') or result.get('errorMessage') or 'Safaricom rejected the STK request.'
            raise StkPushError(message)

        push_request.merchant_request_id = str(result.get('MerchantRequestID', ''))[:100]
        push_request.checkout_request_id = str(result['CheckoutRequestID'])[:100]
        push_request.status = StkPushRequest.Status.PENDING
        push_request.result_description = str(result.get('CustomerMessage', 'STK prompt sent.'))[:2000]
        push_request.save(update_fields=['merchant_request_id', 'checkout_request_id', 'status', 'result_description', 'updated_at'])
        return push_request
    except StkPushError as exc:
        push_request.status = StkPushRequest.Status.FAILED
        push_request.result_description = str(exc)[:2000]
        push_request.save(update_fields=['status', 'result_description', 'updated_at'])
        raise
    except (requests.RequestException, ValueError, KeyError) as exc:
        logger.exception('Daraja STK Push request failed for order %s', order.pk)
        push_request.status = StkPushRequest.Status.FAILED
        push_request.result_description = 'Safaricom could not be reached. Use the PayBill fallback.'
        push_request.save(update_fields=['status', 'result_description', 'updated_at'])
        raise StkPushError('Could not send the M-Pesa prompt. Use the PayBill fallback or try again.') from exc


@transaction.atomic
def process_stk_callback(payload: dict) -> dict:
    body = payload.get('Body') or {}
    callback = body.get('stkCallback') or {}
    checkout_id = callback.get('CheckoutRequestID')
    if not checkout_id:
        return {'success': False, 'message': 'Missing CheckoutRequestID'}

    try:
        push_request = StkPushRequest.objects.select_for_update().select_related('order').get(checkout_request_id=checkout_id)
    except StkPushRequest.DoesNotExist:
        logger.warning('STK callback received for unknown CheckoutRequestID %s', checkout_id)
        return {'success': False, 'message': 'Unknown checkout request'}

    if push_request.status == StkPushRequest.Status.SUCCEEDED:
        return {'success': True, 'message': 'Already processed'}

    result_code = callback.get('ResultCode')
    push_request.callback_payload = payload
    push_request.result_code = int(result_code) if result_code is not None else None
    push_request.result_description = str(callback.get('ResultDesc', ''))[:2000]

    if str(result_code) != '0':
        push_request.status = StkPushRequest.Status.FAILED
        push_request.save(update_fields=['callback_payload', 'result_code', 'result_description', 'status', 'updated_at'])
        logger.warning(
            'STK payment failed for order %s, checkout %s: result code %s (%s)',
            push_request.order_id,
            checkout_id,
            result_code,
            push_request.result_description,
        )
        return {'success': True, 'message': 'Payment was not completed'}

    metadata_items = ((callback.get('CallbackMetadata') or {}).get('Item') or [])
    metadata = {item.get('Name'): item.get('Value') for item in metadata_items if isinstance(item, dict) and item.get('Name')}
    receipt = str(metadata.get('MpesaReceiptNumber') or '')
    amount = metadata.get('Amount')
    callback_phone = metadata.get('PhoneNumber')
    try:
        phone_matches = not callback_phone or normalize_ke_phone(str(callback_phone)) == push_request.phone_number
        amount_matches = amount is not None and Decimal(str(amount)) == push_request.amount
    except (StkPushError, ArithmeticError, ValueError):
        phone_matches = False
        amount_matches = False
    if not receipt or not phone_matches or not amount_matches:
        push_request.status = StkPushRequest.Status.FAILED
        push_request.result_description = 'Successful callback did not match the expected amount or receipt.'
        push_request.save(update_fields=['callback_payload', 'result_code', 'result_description', 'status', 'updated_at'])
        logger.error('STK callback payment details did not match order %s', push_request.order_id)
        return {'success': False, 'message': 'Payment details did not match'}

    transaction_time = metadata.get('TransactionDate') or timezone.localtime().strftime('%Y%m%d%H%M%S')
    from apps.paybill.services.ipn_handler import IPNHandler
    result = IPNHandler.process_callback({
        'TransactionCode': receipt,
        'Amount': str(amount),
        'AccountNumber': push_request.order.account_number,
        'PhoneNumber': str(metadata.get('PhoneNumber') or push_request.phone_number),
        'Time': str(transaction_time),
        'BusinessShortCode': str(getattr(settings, 'MPESA_PAYBILL_NUMBER', '')),
        'TransactionType': 'CustomerPayBillOnline',
    })
    if result.get('success') and result.get('order_id') == push_request.order_id:
        push_request.status = StkPushRequest.Status.SUCCEEDED
        push_request.result_description = 'Payment confirmed.'
    else:
        push_request.status = StkPushRequest.Status.FAILED
        push_request.result_description = str(result.get('message', 'Payment was not matched to this order.'))[:2000]
    push_request.callback_payload = payload
    push_request.save(update_fields=['callback_payload', 'status', 'result_description', 'updated_at'])
    if not result.get('success'):
        logger.error(
            'STK receipt reconciliation failed for order %s, checkout %s: %s',
            push_request.order_id,
            checkout_id,
            result.get('message', 'unknown reconciliation error'),
        )
    return result
