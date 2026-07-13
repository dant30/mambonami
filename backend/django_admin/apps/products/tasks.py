# backend/django_admin/apps/products/tasks.py
from datetime import timedelta

from celery import shared_task
from django.db.models import DateField, ExpressionWrapper, F, Value
from django.utils import timezone

from apps.notifications.models import Notification
from apps.notifications.tasks import send_notification_task
from .models import InventoryAlert, InventoryAlertRule, Product


@shared_task
def deactivate_expired_products():
    """Deactivate products whose harvest date plus shelf life has passed."""
    expiry_date = ExpressionWrapper(
        F('harvest_date') + (F('shelf_life_days') * Value(timedelta(days=1))),
        output_field=DateField()
    )
    expired_products = (
        Product.objects
        .annotate(expiry_date=expiry_date)
        .filter(expiry_date__lt=timezone.now().date(), is_active=True)
    )
    count = expired_products.update(is_active=False)
    return f"Deactivated {count} expired products."


@shared_task
def check_low_stock_products():
    """Create low-stock alerts whenever a product drops below its minimum stock level."""
    products = Product.objects.filter(is_active=True).select_related('farmer', 'farmer__user')
    created = 0
    for product in products:
        threshold = product.min_stock_level or 0
        rule = (
            InventoryAlertRule.objects.filter(
                farmer=product.farmer,
                alert_type='stock_low',
                enabled=True,
            )
            .order_by('-created_at')
            .first()
        )
        if rule and rule.threshold_quantity > 0:
            threshold = rule.threshold_quantity

        if threshold <= 0 or product.available_quantity > threshold:
            continue

        existing_alert = product.inventory_alerts.filter(alert_type='stock_low', is_active=True).first()
        if existing_alert:
            continue

        severity = 'critical' if product.available_quantity <= 0 else 'warning'
        message = (
            f"Low stock alert for {product.name}: "
            f"{product.available_quantity} {product.unit} remaining."
        )
        alert = InventoryAlert.objects.create(
            product=product,
            alert_type='stock_low',
            severity=severity,
            message=message,
        )
        notification = Notification.objects.create(
            user=product.farmer.user,
            channel=Notification.Channel.IN_APP,
            category=Notification.Category.SYSTEM,
            priority=Notification.Priority.HIGH if severity == 'critical' else Notification.Priority.NORMAL,
            title='Low stock alert',
            body=message,
            metadata={'product_id': product.id, 'alert_id': alert.id, 'alert_type': alert.alert_type},
            delivery_status=Notification.DeliveryStatus.PENDING,
        )
        send_notification_task.delay(notification.id)
        created += 1
    return f"Created {created} low-stock alerts."


@shared_task
def check_expiring_products():
    """Create expiry alerts for products that are nearing their shelf-life threshold."""
    today = timezone.now().date()
    products = Product.objects.filter(is_active=True, expiry_date__isnull=False).select_related('farmer', 'farmer__user')
    created = 0
    for product in products:
        rule = (
            InventoryAlertRule.objects.filter(
                farmer=product.farmer,
                alert_type='shelf_life',
                enabled=True,
            )
            .order_by('-created_at')
            .first()
        )
        threshold_days = (rule.threshold_days if rule and rule.threshold_days else 3)
        expiry_cutoff = today + timedelta(days=threshold_days)
        if product.expiry_date > expiry_cutoff:
            continue

        existing_alert = product.inventory_alerts.filter(alert_type='shelf_life', is_active=True).first()
        if existing_alert:
            continue

        severity = 'critical' if product.expiry_date <= today else 'warning'
        message = (
            f"Expiry alert for {product.name}: expires on {product.expiry_date}."
        )
        alert = InventoryAlert.objects.create(
            product=product,
            alert_type='shelf_life',
            severity=severity,
            message=message,
        )
        notification = Notification.objects.create(
            user=product.farmer.user,
            channel=Notification.Channel.IN_APP,
            category=Notification.Category.SYSTEM,
            priority=Notification.Priority.HIGH if severity == 'critical' else Notification.Priority.NORMAL,
            title='Expiry alert',
            body=message,
            metadata={'product_id': product.id, 'alert_id': alert.id, 'alert_type': alert.alert_type},
            delivery_status=Notification.DeliveryStatus.PENDING,
        )
        send_notification_task.delay(notification.id)
        created += 1
    return f"Created {created} expiry alerts."