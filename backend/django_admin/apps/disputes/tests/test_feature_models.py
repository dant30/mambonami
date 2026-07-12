from django.test import TestCase
from apps.disputes.models import Dispute, DisputeEvent
from apps.orders.models import Order
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
