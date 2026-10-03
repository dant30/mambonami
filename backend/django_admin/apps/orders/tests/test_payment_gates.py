from decimal import Decimal
from types import SimpleNamespace
from unittest.mock import Mock, patch

from django.core.exceptions import ValidationError
from django.test import SimpleTestCase

from apps.orders.services.state_machine import OrderStateMachine


class SuccessfulPaymentGateTests(SimpleTestCase):
    def test_missing_transaction_reference_is_not_paid(self):
        order = SimpleNamespace(paybill_transaction_code='')
        self.assertFalse(OrderStateMachine.has_successful_payment(order))

    @patch('apps.orders.services.state_machine.PaymentAllocation.objects.filter')
    @patch('apps.orders.services.state_machine.PayBillTransaction.objects.filter')
    def test_matching_transaction_without_allocation_is_not_paid(self, transaction_filter, allocation_filter):
        payment = SimpleNamespace(amount=Decimal('450.00'))
        transaction_filter.return_value.first.return_value = payment
        allocation_filter.return_value.exists.return_value = False
        order = SimpleNamespace(paybill_transaction_code='MPESA123')

        self.assertFalse(OrderStateMachine.has_successful_payment(order))

    @patch('apps.orders.services.state_machine.PaymentAllocation.objects.filter')
    @patch('apps.orders.services.state_machine.PayBillTransaction.objects.filter')
    def test_matched_transaction_with_allocation_is_paid(self, transaction_filter, allocation_filter):
        payment = SimpleNamespace(amount=Decimal('450.00'))
        transaction_filter.return_value.first.return_value = payment
        allocation_filter.return_value.exists.return_value = True
        order = SimpleNamespace(paybill_transaction_code='MPESA123')

        self.assertTrue(OrderStateMachine.has_successful_payment(order))

    @patch('apps.orders.services.state_machine.OrderStateMachine.has_successful_payment', return_value=False)
    def test_paid_status_transition_requires_reconciled_payment(self, _has_payment):
        order = SimpleNamespace(status='placed')
        with self.assertRaises(ValidationError):
            OrderStateMachine.transition(order, 'paid_escrow')
