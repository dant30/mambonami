# backend/django_admin/apps/notifications/signals.py
import logging

from django.db import transaction
from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver
from apps.orders.models import Order
from apps.logistics.models import Trip
from apps.disputes.models import Dispute
from .models import Notification
from .tasks import send_notification_task

logger = logging.getLogger(__name__)


def _queue_notification(notification_id):
    try:
        send_notification_task.delay(notification_id)
    except Exception:
        logger.exception('Could not queue notification %s; it remains pending for retry', notification_id)


def _queue_after_commit(notification):
    transaction.on_commit(lambda: _queue_notification(notification.pk))


def _create_and_queue_notification(notification_data):
    try:
        notification = Notification.objects.create(**notification_data)
        _queue_notification(notification.pk)
    except Exception:
        logger.exception('Could not create or queue order notification')


def _create_order_notification_after_commit(**notification_data):
    transaction.on_commit(lambda: _create_and_queue_notification(notification_data))


@receiver(pre_save, sender=Order, dispatch_uid='order_status_snapshot')
def _snapshot_order_status(sender, instance, **kwargs):
    if not instance.pk:
        instance._previous_status = None
        return

    instance._previous_status = (
        Order.objects.filter(pk=instance.pk).values_list('status', flat=True).first()
    )


@receiver(post_save, sender=Order)
def order_notification(sender, instance, created, **kwargs):
    if created:
        _create_order_notification_after_commit(
            user=instance.buyer,
            channel=Notification.Channel.IN_APP,
            category=Notification.Category.ORDER,
            priority=Notification.Priority.NORMAL,
            title='Order Placed',
            body=f"Your order #{instance.id} has been placed. Payment is pending.",
            metadata={'order_id': str(instance.id), 'status': instance.status},
            delivery_status=Notification.DeliveryStatus.PENDING,
        )
        return

    previous_status = getattr(instance, '_previous_status', None)
    if previous_status == 'paid_escrow' or instance.status != 'paid_escrow':
        return

    sub_orders = instance.sub_orders.select_related('farmer__user').all()
    for sub_order in sub_orders:
        _create_order_notification_after_commit(
            user=sub_order.farmer.user,
            channel=Notification.Channel.WHATSAPP,
            category=Notification.Category.PAYMENT,
            priority=Notification.Priority.HIGH,
            title='Order Paid',
            body=f"Order #{instance.id} has been paid. Please confirm within 30 minutes.",
            metadata={'order_id': str(instance.id), 'sub_order_id': str(sub_order.id)},
            delivery_status=Notification.DeliveryStatus.PENDING,
        )


@receiver(post_save, sender=Trip)
def trip_notification(sender, instance, created, **kwargs):
    if instance.status == 'assigned' and instance.provider:
        notif = Notification.objects.create(
            user=instance.provider.user,
            channel=Notification.Channel.PUSH,
            category=Notification.Category.DELIVERY,
            priority=Notification.Priority.HIGH,
            title='New Delivery Assignment',
            body=f"Pick up order #{instance.order.id} from farm.",
            metadata={'order_id': instance.order.id, 'trip_id': instance.id},
            delivery_status=Notification.DeliveryStatus.PENDING,
        )
        _queue_after_commit(notif)
    elif instance.status == 'delivered':
        buyer = instance.order.buyer
        notif = Notification.objects.create(
            user=buyer,
            channel=Notification.Channel.IN_APP,
            category=Notification.Category.DELIVERY,
            priority=Notification.Priority.NORMAL,
            title='Delivery Confirmed',
            body=f"Your order #{instance.order.id} has been delivered. Rate your experience.",
            metadata={'order_id': instance.order.id},
            delivery_status=Notification.DeliveryStatus.PENDING,
        )
        _queue_after_commit(notif)


@receiver(post_save, sender=Dispute)
def dispute_notification(sender, instance, created, **kwargs):
    if created:
        from django.contrib.auth.models import User
        admins = User.objects.filter(is_staff=True)
        for admin in admins:
            notif = Notification.objects.create(
                user=admin,
                channel=Notification.Channel.EMAIL,
                category=Notification.Category.DISPUTE,
                priority=Notification.Priority.HIGH,
                title='New Dispute Raised',
                body=f"Dispute #{instance.id} for order {instance.order.id}. Reason: {instance.reason}",
                metadata={'dispute_id': instance.id},
                delivery_status=Notification.DeliveryStatus.PENDING,
            )
            _queue_after_commit(notif)