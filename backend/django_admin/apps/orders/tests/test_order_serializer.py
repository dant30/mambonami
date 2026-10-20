from datetime import date
from decimal import Decimal
from unittest.mock import patch

from django.test import SimpleTestCase, TestCase
from rest_framework.exceptions import ValidationError

from apps.orders.serializers import OrderCreateSerializer
from apps.products.models import BulkPriceTier, Product, ProductCategory
from apps.products.services.pricing import resolve_unit_price
from apps.users.models import FarmerProfile, User


class OrderCreateSerializerTests(SimpleTestCase):
    def test_optional_landmark_uses_blank_string_not_null(self):
        field = OrderCreateSerializer().fields['delivery_landmark']

        self.assertEqual(field.run_validation(''), '')
        with self.assertRaises(ValidationError):
            field.run_validation(None)


class DuplicateCartLineTests(TestCase):
    def setUp(self):
        self.buyer = User.objects.create_user(
            phone='+254700000094',
            username='duplicate-cart-buyer',
            password='TestPassword123!',
            role='buyer',
        )
        farmer_user = User.objects.create_user(
            phone='+254700000095',
            username='duplicate-cart-farmer',
            password='TestPassword123!',
            role='farmer',
        )
        farmer = FarmerProfile.objects.get(user=farmer_user)
        category = ProductCategory.objects.create(code='DUP', name='Duplicate lines')
        self.product = Product.objects.create(
            farmer=farmer,
            category=category,
            name='Duplicate-line tomatoes',
            price_per_unit=Decimal('50.00'),
            available_quantity=Decimal('100.00'),
            unit='kg',
            harvest_date=date.today(),
        )

    @patch('apps.products.signals.RedisCache.delete')
    def test_duplicate_product_lines_use_coalesced_quantity_tier(self, _delete_cache):
        BulkPriceTier.objects.create(
            product=self.product,
            buyer_role='any',
            minimum_quantity=Decimal('6.00'),
            unit_price=Decimal('45.00'),
        )
        BulkPriceTier.objects.create(
            product=self.product,
            buyer_role='any',
            minimum_quantity=Decimal('12.00'),
            unit_price=Decimal('38.00'),
        )
        serializer = OrderCreateSerializer(data={
            'delivery_address': 'Near farm',
            'delivery_lat': '1.000000',
            'delivery_lng': '37.000000',
            'scheduled_date': date.today().isoformat(),
            'scheduled_time_window': '09:00-12:00',
            'items': [
                {'product_uuid': str(self.product.uuid), 'quantity': '6.00'},
                {'product_uuid': str(self.product.uuid), 'quantity': '6.00'},
            ],
        }, context={'request': type('Request', (), {'user': self.buyer})()})

        self.assertTrue(serializer.is_valid(), serializer.errors)
        self.assertEqual(len(serializer.validated_data['items']), 1)
        self.assertEqual(serializer.validated_data['items'][0]['quantity'], Decimal('12.00'))
        grouped_items = next(iter(serializer.validated_data['grouped_products'].values()))
        self.assertEqual(grouped_items[0]['quantity'], Decimal('12.00'))
        self.assertEqual(
            resolve_unit_price(self.product, self.buyer.role, grouped_items[0]['quantity']),
            Decimal('38.00'),
        )
