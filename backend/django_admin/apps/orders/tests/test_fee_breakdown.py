from decimal import Decimal
from types import SimpleNamespace

from django.test import SimpleTestCase

from apps.orders.services.order_service import calculate_order_fee_breakdown


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
