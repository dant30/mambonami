from django.test import TestCase
from apps.notifications.models import NotificationPreference
from apps.users.models import User


class NotificationPreferenceTests(TestCase):
    def test_notification_preference_can_be_saved(self):
        user = User.objects.create_user(
            phone='+254700000003',
            username='notif-user',
            password='StrongPass123!',
            role='buyer',
        )
        pref = NotificationPreference.objects.create(
            user=user,
            channel='email',
            category='order',
            enabled=True,
        )
        self.assertTrue(pref.enabled)
        self.assertEqual(pref.category, 'order')
