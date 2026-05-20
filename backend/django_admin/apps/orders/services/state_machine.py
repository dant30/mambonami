# django_admin/apps/orders/services/state_machine.py
# backend/django_admin/apps/orders/services/state_machine.py
from django.core.exceptions import ValidationError
from apps.orders.models import Order, SubOrder

class OrderStateMachine:
    """Validate allowed transitions."""
    ALLOWED_TRANSITIONS = {
        'cart': ['placed'],
        'placed': ['paid_escrow', 'cancelled'],
        'paid_escrow': ['transport_assigned', 'cancelled'],
        'transport_assigned': ['picked_up', 'cancelled'],
        'picked_up': ['delivered', 'disputed'],
        'delivered': [],
        'cancelled': [],
        'disputed': ['delivered', 'cancelled'],
    }

    @classmethod
    def can_transition(cls, order: Order, new_status: str) -> bool:
        return new_status in cls.ALLOWED_TRANSITIONS.get(order.status, [])

    @classmethod
    def transition(cls, order: Order, new_status: str, user=None):
        if not cls.can_transition(order, new_status):
            raise ValidationError(f"Cannot transition from {order.status} to {new_status}")
        # Optional: user permission checks
        if new_status == 'transport_assigned' and not order.is_fully_confirmed():
            raise ValidationError("Not all farmers have confirmed the order.")
        order.status = new_status
        if new_status == 'delivered':
            order.delivered_at = timezone.now()
        order.save()