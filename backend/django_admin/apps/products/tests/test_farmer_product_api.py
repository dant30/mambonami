from datetime import date

from django.test import TestCase
from rest_framework.test import APIClient

from apps.products.models import Product, ProductCategory
from apps.users.models import FarmerProfile, User


class FarmerProductCreateApiTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            phone='+254700000090',
            username='farmer-product-api',
            password='TestPassword123!',
            role='farmer',
        )
        FarmerProfile.objects.get_or_create(user=self.user)
        self.category = ProductCategory.objects.create(code='TOM', name='Tomato')
        self.client.force_authenticate(user=self.user)

    def test_farmer_can_create_product_without_an_image_using_json(self):
        response = self.client.post(
            '/api/products/farmer/products/',
            {
                'category': self.category.id,
                'name': 'Roma tomatoes',
                'variety': 'Roma',
                'price_per_unit': '120.00',
                'available_quantity': '25.00',
                'reserved_quantity': '0.00',
                'unit': 'kg',
                'harvest_date': date.today().isoformat(),
                'shelf_life_days': 5,
                'weight_per_unit': '1.00',
                'pickup_lat': None,
                'pickup_lng': None,
                'description': 'Fresh tomatoes',
                'is_organic': False,
                'is_active': True,
            },
            format='json',
        )

        self.assertEqual(response.status_code, 201, response.data)
        product = Product.objects.get(name='Roma tomatoes')
        self.assertEqual(product.farmer.user, self.user)
        self.assertFalse(product.image)