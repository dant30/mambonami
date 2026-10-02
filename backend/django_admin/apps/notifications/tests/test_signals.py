from unittest.mock import patch

from django.test import SimpleTestCase

from apps.notifications.signals import _queue_notification


class NotificationQueueTests(SimpleTestCase):
    @patch('apps.notifications.signals.send_notification_task.delay', side_effect=ConnectionError('broker unavailable'))
    def test_broker_failure_does_not_escape_notification_dispatch(self, _delay):
        with self.assertLogs('apps.notifications.signals', level='ERROR'):
            _queue_notification(42)
