# backend/django_admin/apps/notifications/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from apps.orders.models import Order
from apps.logistics.models import Trip
from apps.disputes.models import Dispute
from .models import Notification
from .tasks import send_notification_task

@receiver(post_save, sender=Order)
def order_notification(sender, instance, created, **kwargs):
    if created:
        # Buyer: order placed
        notif = Notification.objects.create(
            user=instance.buyer,
            channel='in_app',
            title='Order Placed',
            body=f"Your order #{instance.id} has been placed. Payment is pending.",
            metadata={'order_id': instance.id, 'status': instance.status}
        )
        send_notification_task.delay(notif.id)
    elif instance.status == 'paid_escrow':
        # Farmer: order confirmed payment
        farmer = instance.farmer_profile.user
        notif = Notification.objects.create(
            user=farmer,
            channel='whatsapp',
            title='Order Paid',
            body=f"Order #{instance.id} has been paid. Please confirm within 30 minutes.",
            metadata={'order_id': instance.id}
        )
        send_notification_task.delay(notif.id)

@receiver(post_save, sender=Trip)
def trip_notification(sender, instance, created, **kwargs):
    if instance.status == 'assigned' and instance.provider:
        notif = Notification.objects.create(
            user=instance.provider.user,
            channel='push',
            title='New Delivery Assignment',
            body=f"Pick up order #{instance.order.id} from farm.",
            metadata={'order_id': instance.order.id, 'trip_id': instance.id}
        )
        send_notification_task.delay(notif.id)
    elif instance.status == 'delivered':
        buyer = instance.order.buyer
        notif = Notification.objects.create(
            user=buyer,
            channel='in_app',
            title='Delivery Confirmed',
            body=f"Your order #{instance.order.id} has been delivered. Rate your experience.",
            metadata={'order_id': instance.order.id}
        )
        send_notification_task.delay(notif.id)

@receiver(post_save, sender=Dispute)
def dispute_notification(sender, instance, created, **kwargs):
    if created:
        # Notify admin (use a group or superusers)
        from django.contrib.auth.models import User
        admins = User.objects.filter(is_staff=True)
        for admin in admins:
            notif = Notification.objects.create(
                user=admin,
                channel='email',
                title='New Dispute Raised',
                body=f"Dispute #{instance.id} for order {instance.order.id}. Reason: {instance.reason}",
                metadata={'dispute_id': instance.id}
            )
            send_notification_task.delay(notif.id)