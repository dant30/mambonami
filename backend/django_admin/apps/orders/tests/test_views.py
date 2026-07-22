from django.test import TestCase

from rest_framework.test import APIRequestFactory, force_authenticate



from apps.orders.views.api import FarmerSubOrdersView

from apps.users.models import User





class FarmerSubOrdersViewTests(TestCase):

    def test_farmer_without_profile_returns_empty_list(self):


        user = User.objects.create_user(

            username='farmer-without-profile',

            phone='254700000001',

            password='testpass123',

            role='farmer',

        )

        user.farmer_profile.delete()
        user = User.objects.get(pk=user.pk)

        request = APIRequestFactory().get('/api/orders/suborders/')

        force_authenticate(request, user=user)



        response = FarmerSubOrdersView.as_view()(request)



        self.assertEqual(response.status_code, 200)

        self.assertEqual(response.data['results'], [])