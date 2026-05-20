# backend/django_admin/apps/users/tasks.py
from celery import shared_task

from django.core.mail import send_mail
from django.conf import settings

@shared_task
def send_welcome_email(user_id):
    from .models import User
    try:
        user = User.objects.get(id=user_id)
        send_mail(
            'Welcome to MAMBONAMI!',
            f'Hi {user.username}, welcome to the platform.',
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False,
        )
    except User.DoesNotExist:
        pass