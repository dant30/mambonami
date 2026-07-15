from django.test import TestCase

from apps.users.models import Role, User
from apps.users.serializers.user_serializer import UserDetailSerializer


class RegistrationResponseTests(TestCase):
    def test_user_detail_serializer_includes_role_and_phone(self):
        user = User.objects.create_user(
            phone='+254700000000',
            username='regtest',
            password='TestPass123!',
            role=Role.BUYER,
        )

        data = UserDetailSerializer(user).data

        self.assertEqual(data['phone'], '+254700000000')
        self.assertEqual(data['role'], Role.BUYER)
        self.assertIn('username', data)
