from django.test import TestCase
from django.test.client import RequestFactory

from apps.orders.views.api import FarmerSubOrdersView
from apps.users.models.user import User


class FarmerSubOrdersViewTests(TestCase):
    def test_farmer_without_profile_returns_empty_queryset(self):
        user = User.objects.create_user(
            username='farmer-no-profile',
            phone='254700000000',
            role='farmer',
            password='secret123',
        )

        request = RequestFactory().get('/api/orders/suborders/')
        request.user = user

        view = FarmerSubOrdersView()
        view.request = request

        queryset = view.get_queryset()

        self.assertEqual(list(queryset), [])
