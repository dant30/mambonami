import json
from datetime import date, datetime
from decimal import Decimal

from django.test import TestCase
from django.urls import reverse

from apps.orders.models import Order
from apps.paybill.models import AccountNumberReservation
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


class C2BCallbackViewTests(TestCase):
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
        self.assertEqual(response['Content-Type'].split(';')[0], 'application/xml')
        self.assertIn('<ResultCode>0</ResultCode>', response.content.decode())

    def test_confirmation_callback_returns_success_response(self):
        payload = {
            'TransactionType': 'CustomerPayBillOnline',
            'TransID': '1234567891',
            'TransTime': '20240101120001',
            'TransAmount': '1200.00',
            'BusinessShortCode': '4749215',
            'BillRefNumber': 'ORD-124',
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
        self.assertEqual(response['Content-Type'].split(';')[0], 'application/xml')
        self.assertIn('<ResultCode>0</ResultCode>', response.content.decode())
