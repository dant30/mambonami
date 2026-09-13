from decimal import Decimal

from django.test import TestCase
from rest_framework.test import APIClient

from apps.orders.models import Order
from apps.payouts.models import Payout
from apps.users.models.user import User


class PayoutListApiTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.farmer = User.objects.create_user(
            phone='+254700000010',
            username='farmer-payout-list',
            role='farmer',
            is_phone_verified=True,
            password='TestPassword123',
        )
        self.other_farmer = User.objects.create_user(
            phone='+254700000011',
            username='other-farmer-payout-list',
            role='farmer',
            is_phone_verified=True,
            password='TestPassword123',
        )
        self.buyer = User.objects.create_user(
            phone='+254700000012',
            username='buyer-payout-list',
            role='buyer',
            is_phone_verified=True,
            password='TestPassword123',
        )
        self.order = Order.objects.create(
            buyer=self.buyer,
            total_amount=Decimal('1200.00'),
            delivery_fee=Decimal('120.00'),
            platform_commission=Decimal('60.00'),
            scheduled_date='2026-09-11',
            scheduled_time_window='10:00-12:00',
        )

    def test_farmer_can_list_only_own_farmer_payouts(self):
        own = Payout.objects.create(
            order=self.order,
            recipient_type='farmer',
            recipient_user=self.farmer,
            amount=Decimal('500.00'),
        )
        Payout.objects.create(
            order=self.order,
            recipient_type='farmer',
            recipient_user=self.other_farmer,
            amount=Decimal('700.00'),
        )

        self.client.force_authenticate(user=self.farmer)
        response = self.client.get('/api/payouts/')

        self.assertEqual(response.status_code, 200)
        self.assertEqual([item['uuid'] for item in response.data], [str(own.uuid)])

    def test_buyer_cannot_list_payouts(self):
        self.client.force_authenticate(user=self.buyer)
        response = self.client.get('/api/payouts/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data, [])
