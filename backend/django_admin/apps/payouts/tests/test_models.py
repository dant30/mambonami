from datetime import date
from decimal import Decimal
from unittest.mock import patch

from django.test import TestCase

from apps.orders.models import Order, SubOrder
from apps.paybill.models import PayBillTransaction, PaymentAllocation
from apps.payouts.models import Payout
from apps.payouts.services.payout_service import release_payment
from apps.users.models import FarmerProfile, User


class RemainingEscrowPayoutTests(TestCase):
	@patch('apps.payouts.services.payout_service._execute_payout')
	@patch('apps.payouts.services.payout_service.get_estimated_float_balance', return_value=Decimal('500.00'))
	def test_partial_refund_scales_farmer_payout_from_remaining_escrow(self, _balance, execute_payout):
		buyer = User.objects.create_user(
			phone='+254700000003',
			username='escrow-buyer',
			password='StrongPass123!',
			role='buyer',
		)
		farmer_user = User.objects.create_user(
			phone='+254700000004',
			username='escrow-farmer',
			password='StrongPass123!',
			role='farmer',
		)
		farmer, _ = FarmerProfile.objects.get_or_create(user=farmer_user)
		order = Order.objects.create(
			buyer=buyer,
			status='delivered',
			total_amount=Decimal('100.00'),
			delivery_fee=Decimal('0.00'),
			account_number='ORD-ESCROW-1',
			paybill_transaction_code='ESCROW-TXN-1',
			scheduled_date=date.today(),
			scheduled_time_window='10:00-12:00',
		)
		sub_order = SubOrder.objects.create(
			order=order,
			farmer=farmer,
			subtotal=Decimal('100.00'),
			farmer_payout=Decimal('92.00'),
		)
		payment = PayBillTransaction.objects.create(
			transaction_code='ESCROW-TXN-1',
			amount=Decimal('100.00'),
			account_number=order.account_number,
			sender_phone=buyer.phone,
			transaction_time='2026-10-21T10:00:00Z',
			status='matched',
			matched_order=order,
			remaining_allocated_amount=Decimal('50.00'),
		)
		PaymentAllocation.objects.create(
			transaction=payment,
			order=order,
			allocation_type='order',
			amount=Decimal('100.00'),
		)

		release_payment(order.pk)

		payout = Payout.objects.get(order=order, recipient_type='farmer')
		self.assertEqual(payout.amount, Decimal('46.00'))
		execute_payout.assert_called_once_with(payout)
