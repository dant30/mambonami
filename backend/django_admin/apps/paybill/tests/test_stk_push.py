from datetime import date
from decimal import Decimal

from django.contrib.auth import get_user_model
from django.test import SimpleTestCase, TestCase

from apps.orders.models import Order
from apps.paybill.models import StkPushRequest
from apps.paybill.services.stk_push import (
    StkPushError,
    _friendly_stk_message,
    normalize_ke_phone,
    process_stk_callback,
)


class KenyanPhoneNormalizationTests(SimpleTestCase):
    def test_local_number_is_converted_to_international_format(self):
        self.assertEqual(normalize_ke_phone('0712345678'), '254712345678')

    def test_international_number_with_plus_is_normalized(self):
        self.assertEqual(normalize_ke_phone('+254 712 345 678'), '254712345678')

    def test_non_kenyan_number_is_rejected(self):
        with self.assertRaises(StkPushError):
            normalize_ke_phone('+15551234567')


class StkPushFriendlyErrorTests(TestCase):
    def test_2029_uses_friendly_message(self):
        self.assertEqual(
            _friendly_stk_message('2029', 'Provider-specific error text'),
            'M-Pesa could not complete this payment request. Please try again or use PayBill.',
        )

    def test_callback_preserves_raw_provider_error_but_returns_friendly_message(self):
        user = get_user_model().objects.create_user(
            phone='254712345678',
            username='stk-failure-buyer',
            password='StrongPass123!',
            role='buyer',
        )
        order = Order.objects.create(
            buyer=user,
            total_amount=Decimal('100.00'),
            delivery_fee=Decimal('0.00'),
            account_number='ORD-STK-2029',
            scheduled_date=date.today(),
            scheduled_time_window='10:00-12:00',
        )
        push_request = StkPushRequest.objects.create(
            order=order,
            phone_number='254712345678',
            amount=Decimal('100.00'),
            status=StkPushRequest.Status.PENDING,
            checkout_request_id='ws_CO_2029_test',
        )
        raw_description = 'Raw Safaricom diagnostic for code 2029'
        payload = {
            'Body': {
                'stkCallback': {
                    'CheckoutRequestID': push_request.checkout_request_id,
                    'ResultCode': 2029,
                    'ResultDesc': raw_description,
                },
            },
        }

        with self.assertLogs('apps.paybill.services.stk_push', level='WARNING') as captured:
            result = process_stk_callback(payload)

        push_request.refresh_from_db()
        friendly_message = _friendly_stk_message('2029', raw_description)
        self.assertFalse(result['success'])
        self.assertEqual(result['message'], friendly_message)
        self.assertEqual(push_request.result_description, friendly_message)
        self.assertEqual(push_request.callback_payload, payload)
        self.assertIn(raw_description, '\n'.join(captured.output))
