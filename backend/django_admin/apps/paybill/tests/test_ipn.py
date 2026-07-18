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
