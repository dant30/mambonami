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
from apps.orders.models.promo import PromoCode


def calculate_order_fee_breakdown(cart_data: dict) -> dict:
    grouped = cart_data.get('grouped_products', {})
    subtotal = Decimal('0')
    total_weight_kg = Decimal('0')

    for products_with_qty in grouped.values():
        for item in products_with_qty:
            product = item['product']
            quantity = item['quantity']
            subtotal += product.price_per_unit * quantity
            total_weight_kg += getattr(product, 'weight_per_unit', Decimal('0')) * quantity

    delivery_distance = Decimal('10')
    try:
        from apps.logistics.services.matching import get_pickup_location
        from apps.orders.models import Order

        order = Order(buyer=None)
        pickup_location = get_pickup_location(order)
        delivery_lat = cart_data.get('delivery_lat')
        delivery_lng = cart_data.get('delivery_lng')
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
    platform_commission = subtotal * Decimal('0.08')
    total_amount = subtotal + delivery_fee
    discount_amount = Decimal('0')

    promo_obj = cart_data.get('_promo_code', None)
    if promo_obj:
        if promo_obj.discount_type == 'fixed':
            discount_amount = promo_obj.discount_value
        elif promo_obj.discount_type == 'percent':
            discount_amount = (total_amount * promo_obj.discount_value) / Decimal('100')
            if promo_obj.max_discount_amount and discount_amount > promo_obj.max_discount_amount:
                discount_amount = promo_obj.max_discount_amount
        if discount_amount > total_amount:
            discount_amount = total_amount
        total_amount -= discount_amount

    return {
        'subtotal': subtotal,
        'delivery_fee': delivery_fee,
        'platform_commission': platform_commission,
        'discount_amount': discount_amount,
        'total_amount': total_amount,
    }


@transaction.atomic
def create_order_from_cart(buyer, cart_data: dict) -> Order:
    """
    cart_data structure:
    {
        'delivery_address': str,
        'delivery_street': str,
        'delivery_city': str,
        'delivery_postal_code': str,
        'delivery_landmark': str,
        'delivery_lat': Decimal,
        'delivery_lng': Decimal,
        'scheduled_date': date,
        'scheduled_time_window': str,
        'items': [...],
        'grouped_products': {farmer_id: [{'product': Product, 'quantity': Decimal}]},
        'promo_code': str (optional),
        '_promo_code': PromoCode instance (validated in serializer, optional)
    }
    """
    grouped = cart_data['grouped_products']

    requested_by_product = {}
    requested_products = {}
    for products_with_qty in grouped.values():
        for item in products_with_qty:
            product_id = item['product'].pk
            requested_by_product[product_id] = requested_by_product.get(product_id, Decimal('0')) + item['quantity']

    locked_products = {
        product.pk: product
        for product in Product.objects.select_for_update().filter(pk__in=requested_by_product, is_active=True)
    }
    if len(locked_products) != len(requested_by_product):
        raise ValidationError('One or more products are no longer available.')
    for product_id, quantity in requested_by_product.items():
        product = locked_products[product_id]
        remaining = product.available_quantity - product.reserved_quantity
        if quantity > remaining:
            raise ValidationError(f'Not enough {product.name} remains in stock.')
        product.reserved_quantity += quantity
        product.save(update_fields=['reserved_quantity', 'updated_at'])
    for products_with_qty in grouped.values():
        for item in products_with_qty:
            requested_products[item['product'].pk] = locked_products[item['product'].pk]
            item['product'] = requested_products[item['product'].pk]

    delivery_address = cart_data.get('delivery_address', '')
    delivery_street = cart_data.get('delivery_street') or ''
    delivery_city = cart_data.get('delivery_city') or ''
    delivery_postal_code = cart_data.get('delivery_postal_code') or ''
    delivery_landmark = cart_data.get('delivery_landmark') or ''
    delivery_lat = cart_data['delivery_lat']
    delivery_lng = cart_data['delivery_lng']
    scheduled_date = cart_data['scheduled_date']
    scheduled_time_window = cart_data['scheduled_time_window']
    promo_code_str = cart_data.get('promo_code', '')
    promo_obj = cart_data.get('_promo_code', None)  # already validated

    # 1. Create main order (placeholder totals)
    order = Order.objects.create(
        buyer=buyer,
        total_amount=0,
        delivery_fee=0,
        platform_commission=0,
        delivery_address=delivery_address,
        delivery_street=delivery_street,
        delivery_city=delivery_city,
        delivery_postal_code=delivery_postal_code,
        delivery_landmark=delivery_landmark,
        delivery_lat=delivery_lat,
        delivery_lng=delivery_lng,
        scheduled_date=scheduled_date,
        scheduled_time_window=scheduled_time_window,
        status='placed',
        promo_code=promo_code_str,  # store raw code
    )

    # 2. Generate account number
    order.account_number = generate_account_number('ORD', order.id, 'Order')
    order.save(update_fields=['account_number'])

    total_order_amount = Decimal('0')
    total_delivery_fee = Decimal('0')
    total_platform_commission = Decimal('0')
    total_weight_kg = Decimal('0')
    subtotal = Decimal('0')

    # 3. Create sub‑orders and items
    for farmer_id, products_with_qty in grouped.items():
        sub_total = Decimal('0')
        items_list = []
        for item in products_with_qty:
            product = item['product']
            quantity = item['quantity']
            line_total = product.price_per_unit * quantity
            sub_total += line_total

            # Weight calculation (if weight_per_unit exists)
            weight_per_unit = getattr(product, 'weight_per_unit', Decimal('0'))
            total_weight_kg += weight_per_unit * quantity

            items_list.append(OrderItem(
                product=product,
                quantity=quantity,
                unit_price=product.price_per_unit,
                total_price=line_total
            ))

        commission = sub_total * Decimal('0.08')
        farmer_payout = sub_total - commission

        sub_order = SubOrder.objects.create(
            order=order,
            farmer_id=farmer_id,
            status='pending',
            subtotal=sub_total,
            farmer_payout=farmer_payout
        )
        for item in items_list:
            item.sub_order = sub_order
        OrderItem.objects.bulk_create(items_list)

        total_order_amount += sub_total
        subtotal += sub_total
        total_platform_commission += commission

    # 4. Calculate delivery fee
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
    total_delivery_fee = delivery_fee
    total_order_amount += delivery_fee

    # 5. Apply promo code discount if valid
    discount_amount = Decimal('0')
    if promo_obj:
        if promo_obj.discount_type == 'fixed':
            discount_amount = promo_obj.discount_value
        elif promo_obj.discount_type == 'percent':
            discount_amount = (total_order_amount * promo_obj.discount_value) / Decimal('100')
            if promo_obj.max_discount_amount and discount_amount > promo_obj.max_discount_amount:
                discount_amount = promo_obj.max_discount_amount
        if discount_amount > total_order_amount:
            discount_amount = total_order_amount
        order.discount_amount = discount_amount
        total_order_amount -= discount_amount
        promo_obj.times_used += 1
        promo_obj.save(update_fields=['times_used'])

    # 6. Update order with final totals
    order.total_amount = total_order_amount
    order.delivery_fee = total_delivery_fee
    order.platform_commission = total_platform_commission
    order.total_weight_kg = total_weight_kg
    order.save(update_fields=[
        'total_amount', 'delivery_fee', 'platform_commission',
        'total_weight_kg', 'discount_amount'
    ])

    breakdown = calculate_order_fee_breakdown({
        'grouped_products': grouped,
        'delivery_lat': delivery_lat,
        'delivery_lng': delivery_lng,
        '_promo_code': promo_obj,
    })
    if breakdown['subtotal'] != subtotal:
        subtotal = breakdown['subtotal']
    if breakdown['delivery_fee'] != total_delivery_fee:
        total_delivery_fee = breakdown['delivery_fee']
    if breakdown['platform_commission'] != total_platform_commission:
        total_platform_commission = breakdown['platform_commission']
    if breakdown['discount_amount'] != discount_amount:
        discount_amount = breakdown['discount_amount']
    if breakdown['total_amount'] != total_order_amount:
        total_order_amount = breakdown['total_amount']

    order.total_amount = total_order_amount
    order.delivery_fee = total_delivery_fee
    order.platform_commission = total_platform_commission
    order.discount_amount = discount_amount
    order.save(update_fields=[
        'total_amount', 'delivery_fee', 'platform_commission', 'discount_amount'
    ])

    return order


@transaction.atomic
def release_order_inventory(order: Order) -> None:
    """Release stock reserved by an order that will not be fulfilled."""
    quantities = {}
    for item in OrderItem.objects.filter(sub_order__order=order).only('product_id', 'quantity'):
        quantities[item.product_id] = quantities.get(item.product_id, Decimal('0')) + item.quantity
    products = Product.objects.select_for_update().filter(pk__in=quantities)
    for product in products:
        reserved = product.reserved_quantity
        quantity = quantities[product.pk]
        if reserved == 0:
            continue
        if reserved < quantity:
            raise ValidationError(f'Inventory reservation for {product.name} is inconsistent.')
        product.reserved_quantity = reserved - quantity
        product.save(update_fields=['reserved_quantity', 'updated_at'])


@transaction.atomic
def consume_order_inventory(order: Order) -> None:
    """Convert an order's reservation into fulfilled stock after delivery proof."""
    quantities = {}
    for item in OrderItem.objects.filter(sub_order__order=order).only('product_id', 'quantity'):
        quantities[item.product_id] = quantities.get(item.product_id, Decimal('0')) + item.quantity
    products = Product.objects.select_for_update().filter(pk__in=quantities)
    if len(products) != len(quantities):
        raise ValidationError('An ordered product no longer exists.')
    for product in products:
        quantity = quantities[product.pk]
        if (product.reserved_quantity not in (0,) and product.reserved_quantity < quantity) or product.available_quantity < quantity:
            raise ValidationError(f'Inventory reservation for {product.name} is inconsistent.')
        if product.reserved_quantity >= quantity:
            product.reserved_quantity -= quantity
        product.available_quantity -= quantity
        product.save(update_fields=['reserved_quantity', 'available_quantity', 'updated_at'])