from django.conf import settings
from django.test import SimpleTestCase, override_settings
from rest_framework.test import APIRequestFactory
from rest_framework.throttling import AnonRateThrottle, ScopedRateThrottle

from apps.products.views.api import ProductListView


class PublicProductThrottleTests(SimpleTestCase):
    @override_settings(REST_FRAMEWORK={**settings.REST_FRAMEWORK, 'NUM_PROXIES': 1})
    def test_anonymous_throttle_uses_client_ip_forwarded_by_proxy(self):
        request = APIRequestFactory().get(
            '/api/products/',
            HTTP_X_FORWARDED_FOR='192.0.2.20, 198.51.100.42',
        )
        request.META['REMOTE_ADDR'] = '127.0.0.1'

        self.assertEqual(AnonRateThrottle().get_ident(request), '198.51.100.42')

    def test_public_product_list_has_its_own_rate_scope(self):
        self.assertEqual(ProductListView.throttle_classes, [ScopedRateThrottle])
        self.assertEqual(ProductListView.throttle_scope, 'public_products')
        self.assertIn(
            'public_products',
            settings.REST_FRAMEWORK['DEFAULT_THROTTLE_RATES'],
        )