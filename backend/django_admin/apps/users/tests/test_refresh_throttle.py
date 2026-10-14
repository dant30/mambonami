from django.test import SimpleTestCase

from apps.users.views.api import CookieTokenRefreshView
from core.throttling import RefreshTokenThrottle


class CookieTokenRefreshThrottleTests(SimpleTestCase):
    def test_refresh_endpoint_uses_a_dedicated_limit(self):
        self.assertEqual(CookieTokenRefreshView.throttle_classes, [RefreshTokenThrottle])
        self.assertEqual(RefreshTokenThrottle.rate, '60/minute')