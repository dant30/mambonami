from datetime import timedelta
from decimal import Decimal

from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient

from apps.orders.models import Order
from apps.payouts.models import Payout
from apps.users.models.user import User


class PayoutSummaryApiTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            phone='+254700000001',
            username='provider1',
            role='transport_provider',
            is_phone_verified=True,
            password='TestPassword123',
        )
        self.buyer = User.objects.create_user(
            phone='+254700000002',
            username='buyer1',
            role='buyer',
            is_phone_verified=True,
            password='TestPassword123',
        )
        self.order = Order.objects.create(
            buyer=self.buyer,
            total_amount=Decimal('1200.00'),
            delivery_fee=Decimal('120.00'),
            platform_commission=Decimal('60.00'),
            scheduled_date=timezone.localdate(),
            scheduled_time_window='10:00-12:00',
        )
        self.client.force_authenticate(user=self.user)

    def test_transport_provider_summary_endpoint_returns_expected_totals(self):
        Payout.objects.create(
            order=self.order,
            recipient_type='transport_provider',
            recipient_user=self.user,
            amount=Decimal('500.00'),
            status='completed',
            paid_at=timezone.now() - timedelta(days=1),
        )
        Payout.objects.create(
            order=self.order,
            recipient_type='transport_provider',
            recipient_user=self.user,
            amount=Decimal('250.00'),
            status='processing',
        )

        response = self.client.get('/api/payouts/summary/')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['total_payout_amount'], '750.00')
        self.assertEqual(response.data['completed_payout_count'], 1)
        self.assertEqual(response.data['pending_payout_amount'], '250.00')
