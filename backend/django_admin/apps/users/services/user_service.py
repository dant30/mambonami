# backend/django_admin/apps/users/services/user_service.py
from typing import Optional
from django.contrib.auth import get_user_model
from django.db import IntegrityError
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


def _resolve_legacy_phone(normalized_phone: str) -> Optional[User]:
    if not normalized_phone:
        return None

    candidates = {normalized_phone}
    if normalized_phone.startswith('+254'):
        digits = normalized_phone[4:]
        candidates.add(f'0{digits}')
        candidates.add(f'254{digits}')
        candidates.add(digits)
    elif normalized_phone.startswith('254'):
        digits = normalized_phone[3:]
        candidates.add(f'0{digits}')
        candidates.add(digits)
        candidates.add(f'+{normalized_phone}')
    elif normalized_phone.startswith('0'):
        digits = normalized_phone[1:]
        candidates.add(f'+254{digits}')
        candidates.add(f'254{digits}')
        candidates.add(digits)
    else:
        candidates.add(f'+254{normalized_phone}')
        candidates.add(f'0{normalized_phone}')
        candidates.add(f'254{normalized_phone}')

    candidates = {candidate for candidate in candidates if candidate}

    user = User.objects.filter(phone__in=candidates).first()
    if user:
        return user

    # Fallback: handle phone values stored with whitespace/dashes/bad formatting
    digits = normalized_phone.lstrip('+')
    legacy_users = User.objects.filter(phone__contains=digits)
    for candidate in legacy_users:
        try:
            if normalize_phone_number(candidate.phone) == normalized_phone:
                return candidate
        except Exception:
            continue

    return None


def authenticate_user(phone: str, password: str) -> Optional[User]:
    try:
        normalized_phone = normalize_phone_number(phone)
    except Exception:
        return None

    user = _resolve_legacy_phone(normalized_phone)
    if not user:
        return None

    if not user.check_password(password):
        return None

    if user.phone != normalized_phone:
        user.phone = normalized_phone
        try:
            user.save(update_fields=['phone'])
        except IntegrityError:
            # If there is a duplicate normalized phone, continue without mutating.
            pass

    return user
