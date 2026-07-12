from django.test import TestCase
from apps.products.models import Product, ProductCategory, InventoryAlert, InventoryAlertRule
from apps.users.models import User, FarmerProfile


class InventoryAlertTests(TestCase):
    def test_inventory_alerts_can_be_created_for_products(self):
        user = User.objects.create_user(
            phone='+254700000004',
            username='alert-farmer',
            password='StrongPass123!',
            role='farmer',
        )
        farmer_profile = FarmerProfile.objects.create(user=user)
        category = ProductCategory.objects.create(code='mango', name='Mango')
        product = Product.objects.create(
            farmer=farmer_profile,
            category=category,
            name='Ngowe Mango',
            price_per_unit=120,
            available_quantity=3,
            unit='kg',
            harvest_date='2024-01-01',
            shelf_life_days=3,
        )
        alert = InventoryAlert.objects.create(
            product=product,
            alert_type='stock_low',
            severity='warning',
            message='Stock is running low',
        )
        rule = InventoryAlertRule.objects.create(
            farmer=farmer_profile,
            alert_type='stock_low',
            threshold_quantity=5,
            enabled=True,
        )
        self.assertEqual(alert.alert_type, 'stock_low')
        self.assertTrue(rule.enabled)
