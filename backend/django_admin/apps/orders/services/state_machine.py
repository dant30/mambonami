# django_admin/apps/orders/services/state_machine.py
# backend/django_admin/apps/orders/services/state_machine.py
from django.core.exceptions import ValidationError
from django.utils import timezone
from django.db import transaction
from apps.orders.models import Order, SubOrder
from apps.paybill.models.allocation import PaymentAllocation
from apps.paybill.models.transaction import PayBillTransaction

class OrderStateMachine:
    """Validate allowed transitions."""
    ALLOWED_TRANSITIONS = {
        'cart': ['placed'],
        'placed': ['paid_escrow', 'cancelled'],
        'paid_escrow': ['transport_assigned'],
        'transport_assigned': ['picked_up'],
        'picked_up': ['delivered', 'disputed'],
        'delivered': [],
        'cancelled': [],
        'disputed': ['delivered', 'cancelled'],
    }

    @classmethod
    def can_transition(cls, order: Order, new_status: str) -> bool:
        return new_status in cls.ALLOWED_TRANSITIONS.get(order.status, [])

    @staticmethod
    def has_successful_payment(order: Order) -> bool:
        transaction_code = order.paybill_transaction_code
        if not transaction_code:
            return False
        payment = PayBillTransaction.objects.filter(
            transaction_code=transaction_code,
            matched_order=order,
            status__in=['matched', 'allocated', 'completed'],
        ).first()
        return bool(payment and PaymentAllocation.objects.filter(
            order=order,
            transaction=payment,
            amount=payment.amount,
            allocation_type='order',
        ).exists())

    @classmethod
    @transaction.atomic
    def transition(cls, order: Order, new_status: str, user=None):
        locked_order = Order.objects.select_for_update().get(pk=order.pk)
        if not cls.can_transition(locked_order, new_status):
            raise ValidationError(f"Cannot transition from {locked_order.status} to {new_status}")
        if new_status in {'paid_escrow', 'transport_assigned', 'picked_up', 'delivered'} and not cls.has_successful_payment(locked_order):
            raise ValidationError("A successfully reconciled payment is required before fulfilment can proceed.")
        if new_status == 'transport_assigned' and not locked_order.are_all_farmers_ready():
            raise ValidationError("All farmers must be ready for transport assignment.")
        if new_status == 'transport_assigned' and not locked_order.assigned_provider_id:
            raise ValidationError("A transport provider must be assigned before the order can advance.")
        if new_status == 'picked_up':
            from apps.logistics.models import Trip, TripStatus

            if not Trip.objects.filter(order=locked_order, status=TripStatus.PICKED_UP).exists():
                raise ValidationError("The assigned transporter must record pickup before the order can advance.")
        if new_status == 'delivered':
            from apps.logistics.models import Trip, TripStatus

            if not Trip.objects.filter(
                order=locked_order,
                status=TripStatus.DELIVERED,
                otp_verified_at__isnull=False,
            ).exists():
                raise ValidationError("Buyer OTP and delivery proof are required before the order can be delivered.")
            from apps.orders.services.order_service import consume_order_inventory

            consume_order_inventory(locked_order)
        if new_status == 'cancelled' and locked_order.status == 'placed':
            from apps.orders.services.order_service import release_order_inventory

            release_order_inventory(locked_order)
        locked_order.status = new_status
        if new_status == 'delivered':
            locked_order.delivered_at = timezone.now()
        locked_order.save(update_fields=['status', 'delivered_at', 'updated_at'] if new_status == 'delivered' else ['status', 'updated_at'])
        order.status = locked_order.status
        order.delivered_at = locked_order.delivered_at
        return locked_order