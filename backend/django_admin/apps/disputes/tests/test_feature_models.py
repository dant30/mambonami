from decimal import Decimal
from types import SimpleNamespace
from unittest.mock import patch

from django.test import TestCase
from apps.disputes.models import Dispute, DisputeEvent
from apps.orders.models import Order
from apps.paybill.models import PayBillTransaction, PaymentAllocation
from apps.users.models import User


class DisputeWorkflowModelTests(TestCase):
    def test_dispute_event_can_be_created_with_escalation_context(self):
        user = User.objects.create_user(
            phone='+254700000001',
            username='dispute-user',
            password='StrongPass123!',
            role='buyer',
        )
        order = Order.objects.create(
            buyer=user,
            status='placed',
            total_amount=100,
            delivery_fee=10,
        )
        dispute = Dispute.objects.create(
            order=order,
            raised_by=user,
            reason='damaged',
            description='Delivery arrived damaged',
            status='open',
            escalation_reason='Escalate to support',
            priority='high',
        )
        event = DisputeEvent.objects.create(
            dispute=dispute,
            actor=user,
            event_type='escalated',
            details='Support review requested',
        )
        self.assertEqual(event.event_type, 'escalated')
        self.assertEqual(dispute.priority, 'high')

    @patch('apps.disputes.services.resolution._execute_payout')
    @patch('apps.disputes.services.resolution.get_estimated_float_balance', return_value=Decimal('500.00'))
    def test_refund_allocation_decrements_remaining_order_escrow(self, _balance, execute_payout):
        buyer = User.objects.create_user(
            phone='+254700000002',
            username='refund-buyer',
            password='StrongPass123!',
            role='buyer',
        )
        order = Order.objects.create(
            buyer=buyer,
            status='paid_escrow',
            total_amount=Decimal('100.00'),
            delivery_fee=Decimal('0.00'),
            account_number='ORD-REFUND-1',
            paybill_transaction_code='REFUND-TXN-1',
            scheduled_date='2026-10-21',
            scheduled_time_window='10:00-12:00',
        )
        payment = PayBillTransaction.objects.create(
            transaction_code='REFUND-TXN-1',
            amount=Decimal('100.00'),
            account_number=order.account_number,
            sender_phone=buyer.phone,
            transaction_time='2026-10-21T10:00:00Z',
            status='matched',
            matched_order=order,
            remaining_allocated_amount=Decimal('100.00'),
        )
        PaymentAllocation.objects.create(
            transaction=payment,
            order=order,
            allocation_type='order',
            amount=Decimal('100.00'),
        )
        dispute = SimpleNamespace(
            id=99,
            order=order,
            refund_amount=Decimal('25.00'),
        )

        from apps.disputes.services.resolution import _apply_refund
        _apply_refund(dispute)

        payment.refresh_from_db()
        self.assertEqual(payment.remaining_allocated_amount, Decimal('75.00'))
        self.assertEqual(
            PaymentAllocation.objects.get(transaction=payment, allocation_type='refund').amount,
            Decimal('-25.00'),
        )
        execute_payout.assert_called_once()
