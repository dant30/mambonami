# backend/django_admin/apps/orders/tasks.py
from celery import shared_task
from django.utils import timezone
from datetime import timedelta
from .models import Order, SubOrder
from apps.logistics.services.matching import find_eligible_providers, assign_provider_to_order
from apps.orders.services.state_machine import OrderStateMachine

@shared_task
def auto_cancel_unpaid_orders():
    """Cancel orders still 'placed' after 30 minutes."""
    cutoff = timezone.now() - timedelta(minutes=30)
    orders = Order.objects.filter(status='placed', created_at__lt=cutoff)
    for order in orders:
        order.status = 'cancelled'
        order.save()
        # Release any reserved stock if needed

@shared_task
def match_transport_for_order(order_id):
    """Async task to find and assign a transport provider."""
    from apps.orders.models import Order
    order = Order.objects.get(id=order_id)
    if order.status != 'paid_escrow' or not OrderStateMachine.has_successful_payment(order):
        return
    if not order.are_all_farmers_ready():
        return
    eligible = find_eligible_providers(order)
    if eligible:
        provider, _fee, _distance = eligible[0]
        assign_provider_to_order(order, provider)
        # Notify provider
    else:
        # Retry after 2 minutes
        match_transport_for_order.apply_async(args=[order_id], countdown=120)

@shared_task
def remind_farmer_to_confirm(suborder_id):
    """Send reminder if farmer hasn't confirmed within 15 minutes."""
    suborder = SubOrder.objects.get(id=suborder_id)
    if suborder.status == 'pending':
        # Send WhatsApp reminder
        pass