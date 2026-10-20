# backend/django_admin/apps/products/signals.py
import logging
from django.db.models import Avg
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from .models import BulkPriceTier, Product
from .models.review import ProductReview
from core.cache import RedisCache

logger = logging.getLogger(__name__)


def invalidate_product_price_cache(product_id):
    RedisCache.delete('product_list_cache')
    RedisCache.delete(f'product_{product_id}')


@receiver(post_save, sender=BulkPriceTier)
def bulk_price_tier_saved(sender, instance, **kwargs):
    invalidate_product_price_cache(instance.product_id)


@receiver(post_delete, sender=BulkPriceTier)
def bulk_price_tier_deleted(sender, instance, **kwargs):
    invalidate_product_price_cache(instance.product_id)

# ─── Product creation log ─────────────────────────────────────────────────────
@receiver(post_save, sender=Product)
def log_product_creation(sender, instance, created, **kwargs):
    if created:
        logger.info(f"New product created: {instance.name} by farmer {instance.farmer.user.phone}")

# ─── Product review updates ──────────────────────────────────────────────────
def update_product_ratings(product):
    """Recalculate average rating and review count."""
    reviews = product.reviews.all()
    count = reviews.count()
    if count:
        avg = reviews.aggregate(avg=Avg('rating'))['avg'] or 0.0
        product.rating = round(avg, 1)
        product.review_count = count
    else:
        product.rating = 5.0
        product.review_count = 0
    product.save(update_fields=['rating', 'review_count'])

@receiver(post_save, sender=ProductReview)
def review_saved(sender, instance, **kwargs):
    update_product_ratings(instance.product)

@receiver(post_delete, sender=ProductReview)
def review_deleted(sender, instance, **kwargs):
    update_product_ratings(instance.product)