# django_admin/apps/orders/services/order_service.py
# backend/django_admin/apps/orders/services/order_service.py
from decimal import Decimal
from django.db import transaction
from django.utils import timezone
from django.core.exceptions import ValidationError
from apps.orders.models import Order, SubOrder, OrderItem
from apps.products.models import Product
from apps.paybill.services.account_number import generate_account_number
from apps.logistics.services.geolocation import haversine
from apps.logistics.services.fee_calculator import estimate_fee as calculate_delivery_fee_estimate

@transaction.atomic
def create_order_from_cart(buyer, cart_data: dict) -> Order:
    """
    cart_data structure:
    {
        'delivery_address': str,
        'delivery_lat': Decimal,
        'delivery_lng': Decimal,
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
    delivery_lat = cart_data['delivery_lat']
    delivery_lng = cart_data['delivery_lng']
    scheduled_date = cart_data['scheduled_date']
    scheduled_time_window = cart_data['scheduled_time_window']

    # 1. Create main order (placeholder totals)
    order = Order.objects.create(
        buyer=buyer,
        total_amount=0,
        delivery_fee=0,
        platform_commission=0,
        delivery_address=delivery_address,
        delivery_lat=delivery_lat,
        delivery_lng=delivery_lng,
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
    total_weight_kg = Decimal('0')

    # 3. Create sub‑orders and items
    for farmer_id, products_with_qty in grouped.items():
        sub_total = Decimal('0')
        items_list = []
        for item in products_with_qty:
            product = item['product']
            quantity = item['quantity']
            line_total = product.price_per_unit * quantity
            sub_total += line_total
            
            # Calculate weight if product has weight_per_unit
            if hasattr(product, 'weight_per_unit') and product.weight_per_unit:
                total_weight_kg += product.weight_per_unit * quantity
            
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

    # 4. Calculate delivery fee estimate from pickup to delivery
    delivery_distance = Decimal('10')
    try:
        from apps.logistics.services.matching import get_pickup_location
        pickup_location = get_pickup_location(order)
        if pickup_location and delivery_lat is not None and delivery_lng is not None:
            delivery_distance = Decimal(str(haversine(
                pickup_location[0], pickup_location[1],
                float(delivery_lat), float(delivery_lng)
            )))
    except Exception:
        delivery_distance = Decimal('10')

    delivery_fee = calculate_delivery_fee_estimate(
        distance_km=float(delivery_distance),
        total_weight_kg=float(total_weight_kg)
    )

    total_order_amount += delivery_fee
    total_delivery_fee = delivery_fee

    # 5. Update order with final totals
    order.total_amount = total_order_amount
    order.delivery_fee = total_delivery_fee
    order.platform_commission = total_platform_commission
    order.total_weight_kg = total_weight_kg
    order.save(update_fields=['total_amount', 'delivery_fee', 'platform_commission', 'total_weight_kg'])

    return order