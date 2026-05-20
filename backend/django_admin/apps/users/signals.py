# backend/django_admin/apps/users/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import User, FarmerProfile, TransportProviderProfile


@receiver(post_save, sender=User)
def create_role_profile(sender, instance, created, **kwargs):
    if not created:
        return

    if instance.role == 'farmer' and not hasattr(instance, 'farmer_profile'):
        FarmerProfile.objects.create(user=instance, mpesa_number=instance.phone)
    elif instance.role == 'transport_provider' and not hasattr(instance, 'transport_profile'):
        TransportProviderProfile.objects.create(user=instance)
