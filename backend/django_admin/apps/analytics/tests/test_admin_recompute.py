from datetime import date
from types import SimpleNamespace
from unittest.mock import patch

from django.test import SimpleTestCase
from rest_framework.test import APIRequestFactory, force_authenticate

from apps.analytics.views.api import DailyMetricViewSet


class AdminMetricsRecomputeTests(SimpleTestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.view = DailyMetricViewSet.as_view({'post': 'recompute'})
        self.admin = SimpleNamespace(
            is_authenticated=True,
            is_staff=True,
            is_superuser=False,
        )

    def post(self, payload):
        request = self.factory.post('/api/analytics/metrics/recompute/', payload, format='json')
        force_authenticate(request, user=self.admin)
        return self.view(request)

    @patch('apps.analytics.services.aggregator.aggregate_range')
    @patch('apps.analytics.tasks.aggregate_metrics_for_range.delay', side_effect=ConnectionError('broker offline'))
    def test_falls_back_to_sync_for_short_range_when_broker_is_offline(self, _delay, aggregate_range):
        today = date.today().isoformat()

        response = self.post({'start_date': today, 'end_date': today})

        self.assertEqual(response.status_code, 200)
        aggregate_range.assert_called_once_with(date.today(), date.today())

    @patch('apps.analytics.tasks.aggregate_metrics_for_range.delay', side_effect=ConnectionError('broker offline'))
    def test_long_range_returns_service_unavailable_when_broker_is_offline(self, _delay):
        response = self.post({'start_date': '2026-10-01', 'end_date': '2026-10-08'})

        self.assertEqual(response.status_code, 503)

    def test_invalid_dates_return_bad_request(self):
        response = self.post({'start_date': 'not-a-date', 'end_date': '2026-10-11'})

        self.assertEqual(response.status_code, 400)