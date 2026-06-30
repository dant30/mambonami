# backend/django_admin/apps/users/services/user_service.py
from typing import Optional
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import RefreshToken
from core.validators.phone_validator import normalize_phone_number

User = get_user_model()

def get_tokens_for_user(user: User):
    refresh = RefreshToken.for_user(user)
    refresh['role'] = user.role
    refresh['phone'] = user.phone
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

def authenticate_user(phone: str, password: str) -> Optional[User]:
    try:
        normalized_phone = normalize_phone_number(phone)
    except Exception:
        return None

    try:
        user = User.objects.get(phone=normalized_phone)
    except User.DoesNotExist:
        return None

    if user.check_password(password):
        return user
    return None
