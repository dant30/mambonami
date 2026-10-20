import json
from datetime import date, datetime
from decimal import Decimal
from unittest.mock import patch

from django.test import TestCase
from django.utils import timezone
from django.urls import reverse

from apps.orders.models import Order
from apps.paybill.models import AccountNumberReservation, PaymentAllocation, PayBillTransaction, StkPushRequest
from apps.paybill.services.payment_service import complete_order_payment
from apps.users.models import Role, User


class PayBillSimulationViewTests(TestCase):
    def setUp(self):
        self.unique_suffix = datetime.now().strftime('%Y%m%d%H%M%S')
        self.phone = f'2547{self.unique_suffix[-9:]}'
        self.account_number = f'ORD-{self.unique_suffix}'
        self.transaction_code = f'SIM-{self.unique_suffix}'
        self.buyer = User.objects.create_user(
            username=f'buyer-sim-{self.unique_suffix}',
            phone=self.phone,
            role=Role.BUYER,
            password='StrongPass123!',
        )
        self.order = Order.objects.create(
            buyer=self.buyer,
            total_amount=Decimal('1200.00'),
            delivery_fee=Decimal('100.00'),
            platform_commission=Decimal('96.00'),
            status='placed',
            account_number=self.account_number,
            delivery_address='Nairobi',
            scheduled_date=date.today(),
            scheduled_time_window='10:00-12:00',
        )
        self.reservation = AccountNumberReservation.objects.create(
            prefix='ORD',
            related_object_id=self.order.id,
            related_object_type='Order',
            account_number=self.account_number,
            is_used=False,
        )

    def test_simulate_payment_marks_order_paid(self):
        payload = {
            'TransactionCode': self.transaction_code,
            'Amount': '1200.00',
            'AccountNumber': self.account_number,
            'PhoneNumber': self.phone,
            'Time': datetime.now().strftime('%Y%m%d%H%M%S'),
            'BillRefNumber': self.account_number,
            'BusinessShortCode': '4749215',
            'TransactionType': 'CustomerPayBillOnline',
        }

        response = self.client.post(
            reverse('paybill_simulate'),
            data=json.dumps(payload),
            content_type='application/json',
            follow=True,
        )

        self.assertEqual(response.status_code, 200)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'paid_escrow')
        self.assertEqual(self.order.paybill_transaction_code, self.transaction_code)

        complete_order_payment(order_id=self.order.id, transaction_code=self.transaction_code)
        complete_order_payment(order_id=self.order.id, transaction_code=self.transaction_code)
        payment = PayBillTransaction.objects.get(transaction_code=self.transaction_code)
        self.assertEqual(payment.remaining_allocated_amount, Decimal('1200.00'))
        self.assertEqual(
            PaymentAllocation.objects.filter(
                transaction=payment,
                order=self.order,
                allocation_type='order',
            ).count(),
            1,
        )

    @patch('apps.paybill.services.payment_service.Order.mark_paid')
    def test_payment_completion_does_not_restore_refunded_escrow_on_retry(self, _mark_paid):
        payment = PayBillTransaction.objects.create(
            transaction_code=f'IDEMPOTENT-{self.unique_suffix}',
            amount=Decimal('1200.00'),
            account_number=self.account_number,
            sender_phone=self.phone,
            transaction_time=timezone.now(),
            status='matched',
            matched_order=self.order,
        )
        complete_order_payment(order_id=self.order.id, transaction_code=payment.transaction_code)
        payment.refresh_from_db()
        PaymentAllocation.objects.create(
            transaction=payment,
            order=self.order,
            allocation_type='refund',
            amount=Decimal('-200.00'),
        )
        payment.remaining_allocated_amount = Decimal('1000.00')
        payment.save(update_fields=['remaining_allocated_amount'])

        complete_order_payment(order_id=self.order.id, transaction_code=payment.transaction_code)

        payment.refresh_from_db()
        self.assertEqual(payment.remaining_allocated_amount, Decimal('1000.00'))

    def test_cancelled_stk_callback_marks_attempt_failed_and_acknowledges_callback(self):
        stk_request = StkPushRequest.objects.create(
            order=self.order,
            phone_number=self.phone,
            amount=self.order.total_amount,
            status=StkPushRequest.Status.PENDING,
            checkout_request_id=f'ws_CO_{self.unique_suffix}',
        )
        response = self.client.post(
            reverse('paybill:stk_push_callback'),
            data=json.dumps({
                'Body': {
                    'stkCallback': {
                        'MerchantRequestID': f'merchant_{self.unique_suffix}',
                        'CheckoutRequestID': stk_request.checkout_request_id,
                        'ResultCode': 1032,
                        'ResultDesc': 'Request cancelled by user',
                    },
                },
            }),
            content_type='application/json',
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['ResultCode'], 0)
        stk_request.refresh_from_db()
        self.order.refresh_from_db()
        self.assertEqual(stk_request.status, StkPushRequest.Status.FAILED)
        self.assertEqual(stk_request.result_description, 'Request cancelled by user')
        self.assertEqual(self.order.status, 'placed')


class C2BCallbackViewTests(TestCase):
    def setUp(self):
        self.unique_suffix = datetime.now().strftime('%Y%m%d%H%M%S%f')
        self.phone = '254712345678'
        self.account_number = f'ORD-{self.unique_suffix}'
        self.transaction_code = f'C2B-{self.unique_suffix}'
        self.buyer = User.objects.create_user(
            username=f'buyer-c2b-{self.unique_suffix}',
            phone=self.phone,
            role=Role.BUYER,
            password='StrongPass123!',
        )
        self.order = Order.objects.create(
            buyer=self.buyer,
            total_amount=Decimal('1200.00'),
            delivery_fee=Decimal('100.00'),
            platform_commission=Decimal('96.00'),
            status='placed',
            account_number=self.account_number,
            delivery_address='Nairobi',
            scheduled_date=date.today(),
            scheduled_time_window='10:00-12:00',
        )
        AccountNumberReservation.objects.create(
            prefix='ORD',
            related_object_id=self.order.id,
            related_object_type='Order',
            account_number=self.account_number,
            is_used=False,
        )

    def test_validation_callback_returns_success_response(self):
        payload = {
            'TransactionType': 'CustomerPayBillOnline',
            'TransID': '1234567890',
            'TransTime': '20240101120000',
            'TransAmount': '1200.00',
            'BusinessShortCode': '4749215',
            'BillRefNumber': 'ORD-123',
            'InvoiceNumber': '',
            'OrgAccountBalance': '10000.00',
            'ThirdPartyTransID': '',
            'MSISDN': '254712345678',
            'FirstName': 'Jane',
            'MiddleName': '',
            'LastName': 'Doe',
        }

        response = self.client.post(
            reverse('paybill:c2b_validation'),
            data=payload,
            content_type='application/json',
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['ResultCode'], 0)

    def test_confirmation_callback_processes_real_daraja_payload(self):
        payload = {
            'TransactionType': 'CustomerPayBillOnline',
            'TransID': self.transaction_code,
            'TransTime': datetime.now().strftime('%Y%m%d%H%M%S'),
            'TransAmount': '1200.00',
            'BusinessShortCode': '4749215',
            'BillRefNumber': self.account_number,
            'InvoiceNumber': '',
            'OrgAccountBalance': '10000.00',
            'ThirdPartyTransID': '',
            'MSISDN': '254712345679',
            'FirstName': 'Jane',
            'MiddleName': '',
            'LastName': 'Doe',
        }

        response = self.client.post(
            reverse('paybill:c2b_confirmation'),
            data=payload,
            content_type='application/json',
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['ResultCode'], 0)
        self.order.refresh_from_db()
        self.assertEqual(self.order.status, 'paid_escrow')
        self.assertEqual(self.order.paybill_transaction_code, self.transaction_code)
