from unittest.mock import patch
from types import SimpleNamespace

from django.test import SimpleTestCase

from apps.notifications.signals import _queue_notification, order_notification


class NotificationQueueTests(SimpleTestCase):
    @patch('apps.notifications.signals.send_notification_task.delay', side_effect=ConnectionError('broker unavailable'))
    def test_broker_failure_does_not_escape_notification_dispatch(self, _delay):
        with self.assertLogs('apps.notifications.signals', level='ERROR'):
            _queue_notification(42)


class OrderNotificationSignalTests(SimpleTestCase):
    @patch('apps.notifications.signals._queue_notification')
    @patch('apps.notifications.signals.Notification.objects.create')
    def test_paid_transition_notifies_each_suborder_farmer(self, create_notification, _queue):
        buyer_farmer = SimpleNamespace(user=SimpleNamespace(pk=21))
        another_farmer = SimpleNamespace(user=SimpleNamespace(pk=22))
        order = SimpleNamespace(
            id='order-1',
            pk='order-1',
            status='paid_escrow',
            _previous_status='placed',
            sub_orders=SimpleNamespace(
                select_related=lambda *_: SimpleNamespace(
                    all=lambda: [
                        SimpleNamespace(id='sub-1', farmer=buyer_farmer),
                        SimpleNamespace(id='sub-2', farmer=another_farmer),
                    ]
                )
            ),
        )

        create_notification.side_effect = [SimpleNamespace(pk=101), SimpleNamespace(pk=102)]
        order_notification(sender=None, instance=order, created=False)

        self.assertEqual(create_notification.call_count, 2)
        self.assertEqual(create_notification.call_args_list[0].kwargs['user'], buyer_farmer.user)
        self.assertEqual(create_notification.call_args_list[1].kwargs['user'], another_farmer.user)
        self.assertEqual(_queue.call_count, 2)

    @patch('apps.notifications.signals.Notification.objects.create')
    def test_paid_order_resave_does_not_send_duplicate_notification(self, create_notification):
        order = SimpleNamespace(
            id='order-1',
            pk='order-1',
            status='paid_escrow',
            _previous_status='paid_escrow',
            sub_orders=None,
        )

        order_notification(sender=None, instance=order, created=False)

        create_notification.assert_not_called()

    @patch('apps.notifications.signals.Notification.objects.create', side_effect=RuntimeError('database unavailable'))
    def test_order_notification_failure_does_not_escape_signal(self, _create_notification):
        order = SimpleNamespace(
            id='order-1',
            pk='order-1',
            status='paid_escrow',
            _previous_status='placed',
            sub_orders=SimpleNamespace(
                select_related=lambda *_: SimpleNamespace(
                    all=lambda: [SimpleNamespace(id='sub-1', farmer=SimpleNamespace(user=object()))]
                )
            ),
        )

        with self.assertLogs('apps.notifications.signals', level='ERROR'):
            order_notification(sender=None, instance=order, created=False)
