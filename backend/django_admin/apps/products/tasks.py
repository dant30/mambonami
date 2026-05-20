# backend/django_admin/apps/products/tasks.py
from celery import shared_task
from django.db.models import F, ExpressionWrapper, DateField, Value
from django.utils import timezone
from datetime import timedelta
from .models import Product

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