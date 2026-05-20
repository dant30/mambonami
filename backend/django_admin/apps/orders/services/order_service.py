# django_admin/apps/orders/services/order_service.py
# backend/django_admin/apps/orders/services/order_service.py
from decimal import Decimal
from django.db import transaction
from django.utils import timezone
from django.core.exceptions import ValidationError
from apps.orders.models import Order, SubOrder, OrderItem
from apps.products.models import Product
from apps.paybill.services.account_number import generate_account_number

def calculate_delivery_fee(distance_km: float, total_weight_kg: float, vehicle_type: str = None) -> Decimal:
    """MVP: base fee 50 KES/km, plus weight surcharge."""
    base = Decimal(str(distance_km)) * Decimal('50')
    if total_weight_kg > 50:
        base += Decimal('200')      # bulky surcharge
    if vehicle_type == 'lorry':
        base += Decimal('300')      # extra for large vehicles
    return base

@transaction.atomic
def create_order_from_cart(buyer, cart_data: dict) -> Order:
    """
    cart_data structure:
    {
        'delivery_address': str,
        'scheduled_date': date,
        'scheduled_time_window': str,
        'items': [
            {'product_uuid': uuid, 'quantity': Decimal},
            ...
        ],
        'grouped_products': {farmer_id: [{'product': Product, 'quantity': Decimal}]}
    }
    """
    grouped = cart_data['grouped_products']
    delivery_address = cart_data['delivery_address']
    scheduled_date = cart_data['scheduled_date']
    scheduled_time_window = cart_data['scheduled_time_window']

    # 1. Create main order (placeholder totals)
    order = Order.objects.create(
        buyer=buyer,
        total_amount=0,
        delivery_fee=0,
        platform_commission=0,
        delivery_address=delivery_address,
        scheduled_date=scheduled_date,
        scheduled_time_window=scheduled_time_window,
        status='placed'
    )

    # 2. Generate account number
    order.account_number = generate_account_number('ORD', order.id, 'Order')
    order.save(update_fields=['account_number'])

    total_order_amount = Decimal('0')
    total_delivery_fee = Decimal('0')
    total_platform_commission = Decimal('0')

    # 3. Create sub‑orders and items
    for farmer_id, products_with_qty in grouped.items():
        sub_total = Decimal('0')
        items_list = []
        for item in products_with_qty:
            product = item['product']
            quantity = item['quantity']
            line_total = product.price_per_unit * quantity
            sub_total += line_total
            items_list.append(OrderItem(
                product=product,
                quantity=quantity,
                unit_price=product.price_per_unit,
                total_price=line_total
            ))

        # Commission: 8% of subtotal
        commission = sub_total * Decimal('0.08')
        farmer_payout = sub_total - commission

        # Create SubOrder
        sub_order = SubOrder.objects.create(
            order=order,
            farmer_id=farmer_id,
            status='pending',
            subtotal=sub_total,
            farmer_commission=commission
        )
        # Bulk create items
        for item in items_list:
            item.sub_order = sub_order
        OrderItem.objects.bulk_create(items_list)

        total_order_amount += sub_total
        total_platform_commission += commission

    # 4. Calculate delivery fee (simplified – real distance from farm cluster to buyer)
    # For MVP, use a default distance of 10 km
    total_weight = Decimal('0')   # you would sum product weights if available
    delivery_fee = calculate_delivery_fee(distance_km=10, total_weight_kg=float(total_weight))

    total_order_amount += delivery_fee
    total_delivery_fee = delivery_fee

    # 5. Update order with final totals
    order.total_amount = total_order_amount
    order.delivery_fee = total_delivery_fee
    order.platform_commission = total_platform_commission
    order.save(update_fields=['total_amount', 'delivery_fee', 'platform_commission'])

    return order