# backend/django_admin/apps/users/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import User, FarmerProfile, TransportProviderProfile, BuyerProfile, RetailerProfile, TrustScore


@receiver(post_save, sender=User)
def create_role_profile(sender, instance, created, **kwargs):
    if not created:
        return

    if instance.role == 'farmer' and not hasattr(instance, 'farmer_profile'):
        FarmerProfile.objects.create(user=instance, mpesa_number=instance.phone)
    elif instance.role == 'transport_provider' and not hasattr(instance, 'transport_profile'):
        TransportProviderProfile.objects.create(user=instance)
    elif instance.role == 'buyer' and not hasattr(instance, 'buyer_profile'):
        BuyerProfile.objects.create(user=instance)
    elif instance.role == 'retailer' and not hasattr(instance, 'retailer_profile'):
        RetailerProfile.objects.create(user=instance)


@receiver(post_save, sender=User)
def create_trust_score(sender, instance, created, **kwargs):
    if created:
        TrustScore.objects.get_or_create(user=instance, defaults={'score': 0, 'score_band': 'fair'})