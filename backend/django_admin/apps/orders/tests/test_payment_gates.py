from decimal import Decimal
from types import SimpleNamespace
from unittest.mock import patch

from django.core.exceptions import ValidationError
from django.test import TestCase

from apps.orders.services.state_machine import OrderStateMachine


class SuccessfulPaymentGateTests(TestCase):
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
        order = SimpleNamespace(status='placed', pk=1)
        locked_order = SimpleNamespace(status='placed', pk=1)
        with patch('apps.orders.services.state_machine.Order.objects.select_for_update') as select_for_update:
            select_for_update.return_value.get.return_value = locked_order
            with self.assertRaises(ValidationError):
                OrderStateMachine.transition(order, 'paid_escrow')

    @patch('apps.orders.services.state_machine.OrderStateMachine.has_successful_payment', return_value=True)
    def test_picked_up_transition_requires_trip_pickup_record(self, _has_payment):
        order = SimpleNamespace(status='transport_assigned', pk=1)
        locked_order = SimpleNamespace(status='transport_assigned', pk=1)
        with patch('apps.orders.services.state_machine.Order.objects.select_for_update') as select_for_update, \
             patch('apps.logistics.models.Trip.objects.filter') as trip_filter:
            select_for_update.return_value.get.return_value = locked_order
            trip_filter.return_value.exists.return_value = False
            with self.assertRaises(ValidationError):
                OrderStateMachine.transition(order, 'picked_up')

    @patch('apps.orders.services.state_machine.OrderStateMachine.has_successful_payment', return_value=True)
    def test_delivered_transition_requires_otp_verified_trip(self, _has_payment):
        order = SimpleNamespace(status='picked_up', pk=1)
        locked_order = SimpleNamespace(status='picked_up', pk=1)
        with patch('apps.orders.services.state_machine.Order.objects.select_for_update') as select_for_update, \
             patch('apps.logistics.models.Trip.objects.filter') as trip_filter:
            select_for_update.return_value.get.return_value = locked_order
            trip_filter.return_value.exists.return_value = False
            with self.assertRaises(ValidationError):
                OrderStateMachine.transition(order, 'delivered')
