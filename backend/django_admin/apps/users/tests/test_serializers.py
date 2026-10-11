from django.test import SimpleTestCase

from apps.users.models import Role, User
from apps.users.serializers.admin_serializers import (
    FarmerAdminSerializer,
    StaffAdminSerializer,
    TransportProviderAdminSerializer,
    UserAdminSerializer,
)
from apps.users.serializers.user_serializer import UserDetailSerializer


class UserDetailSerializerTests(SimpleTestCase):
    def test_serializes_user_without_id_verified_field(self):
        user = User(phone='+254700000000', username='tmpuser', role=Role.BUYER)

        data = UserDetailSerializer(user).data

        self.assertEqual(data['phone'], '+254700000000')
        self.assertIn('account_status', data)


class AdminSerializerFieldTests(SimpleTestCase):
    def test_admin_serializers_only_use_current_model_fields(self):
        for serializer_class in (
            UserAdminSerializer,
            FarmerAdminSerializer,
            TransportProviderAdminSerializer,
        ):
            with self.subTest(serializer=serializer_class.__name__):
                serializer_class().fields

        self.assertNotIn('is_id_verified', UserAdminSerializer().fields)
        self.assertNotIn('avatar', FarmerAdminSerializer().fields)
        self.assertNotIn('avatar', TransportProviderAdminSerializer().fields)

    def test_staff_serializer_does_not_allow_privilege_fields(self):
        serializer = StaffAdminSerializer()

        writable_names = {field.field_name for field in serializer._writable_fields}
        self.assertNotIn('role', writable_names)
        self.assertNotIn('is_staff', writable_names)
        self.assertNotIn('is_superuser', writable_names)
        self.assertTrue(serializer.fields['password'].write_only)
