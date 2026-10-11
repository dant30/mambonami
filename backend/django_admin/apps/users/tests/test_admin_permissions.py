from types import SimpleNamespace

from django.test import SimpleTestCase

from apps.users.permissions import IsAdmin, is_admin_user


class AdminPermissionTests(SimpleTestCase):
    def test_superuser_without_staff_flag_is_admin(self):
        user = SimpleNamespace(is_staff=False, is_superuser=True)
        request = SimpleNamespace(
            user=SimpleNamespace(
                is_authenticated=True,
                is_staff=False,
                is_superuser=True,
            )
        )

        self.assertTrue(is_admin_user(user))
        self.assertTrue(IsAdmin().has_permission(request, view=None))

    def test_regular_authenticated_user_is_not_admin(self):
        request = SimpleNamespace(
            user=SimpleNamespace(
                is_authenticated=True,
                is_staff=False,
                is_superuser=False,
            )
        )

        self.assertFalse(IsAdmin().has_permission(request, view=None))
