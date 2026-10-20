from decimal import Decimal
from datetime import date
from types import SimpleNamespace

from django.test import SimpleTestCase, TestCase

from apps.orders.models import Order, OrderItem, SubOrder
from apps.orders.services.order_service import calculate_order_fee_breakdown
from apps.products.models import Product, ProductCategory
from apps.users.models import FarmerProfile, User


class OrderFeeBreakdownTests(SimpleTestCase):
    def test_calculates_subtotal_delivery_and_platform_fee(self):
        cart_data = {
            'grouped_products': {
                1: [
                    {
                        'product': SimpleNamespace(price_per_unit=Decimal('100'), weight_per_unit=Decimal('2')),
                        'quantity': Decimal('2'),
                    }
                ],
                2: [
                    {
                        'product': SimpleNamespace(price_per_unit=Decimal('50'), weight_per_unit=Decimal('1')),
                        'quantity': Decimal('1'),
                    }
                ],
            },
            'promo_code': '',
        }

        breakdown = calculate_order_fee_breakdown(cart_data)

        self.assertEqual(breakdown['subtotal'], Decimal('250'))
        self.assertEqual(breakdown['platform_commission'], Decimal('20'))
        self.assertEqual(breakdown['discount_amount'], Decimal('0'))
        self.assertEqual(breakdown['total_amount'], breakdown['subtotal'] + breakdown['delivery_fee'])


class OrderFeeDistanceTests(TestCase):
    def test_breakdown_uses_pickup_distance_for_a_neighbor_order(self):
        buyer = User.objects.create_user(
            phone='+254700000091', username='nearby-buyer', password='TestPassword123!', role='buyer'
        )
        farmer_user = User.objects.create_user(
            phone='+254700000092', username='nearby-farmer', password='TestPassword123!', role='farmer'
        )
        farmer = FarmerProfile.objects.get(user=farmer_user)
        category = ProductCategory.objects.create(code='NEI', name='Neighbor Produce')
        product = Product.objects.create(
            farmer=farmer,
            category=category,
            name='Nearby tomatoes',
            price_per_unit=Decimal('100.00'),
            available_quantity=Decimal('10.00'),
            unit='kg',
            harvest_date=date.today(),
            pickup_lat=Decimal('1.000000'),
            pickup_lng=Decimal('37.000000'),
        )
        order = Order.objects.create(
            buyer=buyer,
            total_amount=Decimal('100.00'),
            delivery_fee=Decimal('0.00'),
            platform_commission=Decimal('8.00'),
            delivery_lat=Decimal('1.000000'),
            delivery_lng=Decimal('37.001800'),
            scheduled_date=date.today(),
            scheduled_time_window='09:00-12:00',
        )
        sub_order = SubOrder.objects.create(
            order=order,
            farmer=farmer,
            subtotal=Decimal('100.00'),
            farmer_payout=Decimal('92.00'),
        )
        OrderItem.objects.create(
            sub_order=sub_order,
            product=product,
            quantity=Decimal('1.00'),
            unit_price=Decimal('100.00'),
            total_price=Decimal('100.00'),
        )

        breakdown = calculate_order_fee_breakdown({
            'grouped_products': {farmer.pk: [{'product': product, 'quantity': Decimal('1.00')}]},
            'delivery_lat': order.delivery_lat,
            'delivery_lng': order.delivery_lng,
        }, order=order)

        self.assertAlmostEqual(float(breakdown['delivery_distance_km']), 0.2, places=2)
        self.assertEqual(breakdown['delivery_fee'], Decimal('10'))
