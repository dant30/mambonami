from unittest.mock import Mock, patch

from django.core.exceptions import ValidationError
from django.test import SimpleTestCase

from apps.orders.models import SubOrder


class SubOrderLifecycleTests(SimpleTestCase):
    def make_suborder(self, order_status='placed', suborder_status='pending'):
        suborder = SubOrder(status=suborder_status)
        suborder._state.fields_cache['order'] = Mock(status=order_status)
        return suborder

    def test_unpaid_order_cannot_be_confirmed(self):
        with self.assertRaises(ValidationError):
            self.make_suborder().confirm()

    @patch('apps.orders.services.state_machine.OrderStateMachine.has_successful_payment', return_value=False)
    def test_paid_label_without_reconciled_transaction_cannot_be_confirmed(self, _has_payment):
        with self.assertRaises(ValidationError):
            self.make_suborder(order_status='paid_escrow').confirm()

    @patch('apps.orders.services.state_machine.OrderStateMachine.has_successful_payment', return_value=True)
    def test_unpaid_order_cannot_be_marked_ready(self, _has_payment):
        with self.assertRaises(ValidationError):
            self.make_suborder(order_status='placed', suborder_status='confirmed').mark_ready()

    @patch('apps.orders.services.state_machine.OrderStateMachine.has_successful_payment', return_value=True)
    def test_unconfirmed_suborder_cannot_be_marked_ready(self, _has_payment):
        with self.assertRaises(ValidationError):
            self.make_suborder(order_status='paid_escrow', suborder_status='pending').mark_ready()
