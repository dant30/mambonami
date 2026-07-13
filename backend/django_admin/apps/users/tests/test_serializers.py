from django.test import SimpleTestCase

from apps.users.models import Role, User
from apps.users.serializers.user_serializer import UserDetailSerializer


class UserDetailSerializerTests(SimpleTestCase):
    def test_serializes_user_without_id_verified_field(self):
        user = User(phone='+254700000000', username='tmpuser', role=Role.BUYER)

        data = UserDetailSerializer(user).data

        self.assertEqual(data['phone'], '+254700000000')
        self.assertIn('account_status', data)
