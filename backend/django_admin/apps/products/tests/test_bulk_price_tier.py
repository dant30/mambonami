from datetime import date
from decimal import Decimal
from unittest.mock import patch

from django.test import TestCase

from apps.products.models import BulkPriceTier, Product, ProductCategory
from apps.products.services.pricing import resolve_unit_price
from apps.users.models import FarmerProfile, User


class BulkPriceTierTests(TestCase):
    def setUp(self):
        farmer_user = User.objects.create_user(
            phone='+254700000093',
            username='bulk-tier-farmer',
            password='TestPassword123!',
            role='farmer',
        )
        farmer = FarmerProfile.objects.get(user=farmer_user)
        category = ProductCategory.objects.create(code='BUL', name='Bulk produce')
        self.product = Product.objects.create(
            farmer=farmer,
            category=category,
            name='Bulk tomatoes',
            price_per_unit=Decimal('50.00'),
            available_quantity=Decimal('200.00'),
            unit='kg',
            harvest_date=date.today(),
        )

    @patch('apps.products.signals.RedisCache.delete')
    def test_role_specific_tier_wins_same_quantity_threshold(self, _delete_cache):
        BulkPriceTier.objects.create(
            product=self.product,
            buyer_role='any',
            minimum_quantity=Decimal('6.00'),
            unit_price=Decimal('45.00'),
        )
        BulkPriceTier.objects.create(
            product=self.product,
            buyer_role='retailer',
            minimum_quantity=Decimal('6.00'),
            unit_price=Decimal('42.00'),
        )
        BulkPriceTier.objects.create(
            product=self.product,
            buyer_role='retailer',
            minimum_quantity=Decimal('12.00'),
            unit_price=Decimal('38.00'),
        )

        self.assertEqual(resolve_unit_price(self.product, 'retailer', Decimal('6')), Decimal('42.00'))
        self.assertEqual(resolve_unit_price(self.product, 'retailer', Decimal('12')), Decimal('38.00'))
        self.assertEqual(resolve_unit_price(self.product, 'buyer', Decimal('6')), Decimal('45.00'))
        self.assertEqual(resolve_unit_price(self.product, 'buyer', Decimal('5')), Decimal('50.00'))