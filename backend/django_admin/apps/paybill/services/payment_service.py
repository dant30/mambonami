from django.db import transaction

from apps.orders.models import Order
from apps.paybill.models import PayBillTransaction, PaymentAllocation


class PaymentCompletionError(ValueError):
    pass


@transaction.atomic
def complete_order_payment(*, order_id: int, transaction_code: str) -> tuple[PayBillTransaction, Order]:
    order = Order.objects.select_for_update().get(pk=order_id)
    payment = PayBillTransaction.objects.select_for_update().get(transaction_code=transaction_code)

    if payment.status in {'failed', 'orphaned', 'refunded', 'reversed'}:
        raise PaymentCompletionError(f'A {payment.status} payment cannot be completed.')
    if payment.amount != order.total_amount:
        raise PaymentCompletionError('The payment amount does not match the order total.')
    if payment.matched_order_id not in (None, order.pk):
        raise PaymentCompletionError('The payment is already allocated to another order.')
    if order.paybill_transaction_code and order.paybill_transaction_code != transaction_code:
        raise PaymentCompletionError('The order is already linked to a different payment.')

    if order.status == 'placed':
        order.mark_paid(transaction_code)
    elif order.status not in {'paid_escrow', 'transport_assigned', 'picked_up', 'delivered', 'disputed'}:
        raise PaymentCompletionError(f'An order with status {order.status} cannot be paid.')

    allocation, allocation_created = PaymentAllocation.objects.get_or_create(
        transaction=payment,
        order=order,
        allocation_type='order',
        defaults={'amount': payment.amount},
    )
    if allocation.amount != payment.amount:
        raise PaymentCompletionError('The existing payment allocation amount does not match the transaction.')

    payment.matched_order = order
    payment.status = 'matched'
    update_fields = ['matched_order', 'status']
    if allocation_created:
        payment.remaining_allocated_amount = payment.amount
        update_fields.append('remaining_allocated_amount')
    payment.save(update_fields=update_fields)
    return payment, order