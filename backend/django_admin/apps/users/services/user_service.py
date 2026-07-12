# backend/django_admin/apps/users/services/user_service.py
from typing import Optional, Union
from django.contrib.auth import get_user_model
from django.db import IntegrityError
from django.utils import timezone
from rest_framework_simplejwt.tokens import RefreshToken
from core.validators.phone_validator import normalize_phone_number
from ..models import TrustScore, FarmerProfile, TransportProviderProfile, BuyerProfile, RetailerProfile, Role, AccountStatus

User = get_user_model()


# ────────────────────────────────────────────────────────────────
# AUTHENTICATION & TOKENS
# ────────────────────────────────────────────────────────────────

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


# ────────────────────────────────────────────────────────────────
# ROLE HELPERS
# ────────────────────────────────────────────────────────────────

def has_role(user: User, role: Union[str, list]) -> bool:
    """
    Check if a user has a specific role (or any of the roles in a list).
    """
    if isinstance(role, list):
        return user.role in role
    return user.role == role


def get_user_profile(user: User):
    """
    Return the profile object (FarmerProfile, TransportProviderProfile, etc.)
    based on the user's role. Returns None if no profile exists.
    """
    if user.role == Role.FARMER:
        return getattr(user, 'farmer_profile', None)
    elif user.role == Role.TRANSPORT_PROVIDER:
        return getattr(user, 'transport_profile', None)
    elif user.role == Role.BUYER:
        return getattr(user, 'buyer_profile', None)
    elif user.role == Role.RETAILER:
        return getattr(user, 'retailer_profile', None)
    return None


def get_active_accounts():
    """
    Return a queryset of users with active account status (not banned/suspended).
    """
    return User.objects.filter(account_status__in=[AccountStatus.VERIFIED, AccountStatus.PENDING])


# ────────────────────────────────────────────────────────────────
# TRUST SCORE MANAGEMENT
# ────────────────────────────────────────────────────────────────

def get_or_create_trust_score(user: User) -> TrustScore:
    """
    Retrieve or create a TrustScore record for the given user.
    """
    trust, created = TrustScore.objects.get_or_create(
        user=user,
        defaults={
            'score': 0,
            'score_band': 'fair',
            'reason': 'New user. No activity yet.',
            'verification_level': 'basic',
        }
    )
    if created:
        trust.save()
    return trust


def calculate_trust_score(user: User) -> dict:
    """
    Compute a trust score based on user activity:
    - orders completed
    - disputes raised/received
    - cancellation rate
    - late deliveries (for providers)
    - verification level (KYC status)
    Returns a dict with the computed score, band, and reason.
    """
    # Placeholder: implement actual scoring logic based on your business rules
    # This should aggregate data from orders, disputes, logistics, etc.
    profile = get_user_profile(user)
    if user.role == Role.FARMER:
        orders_completed = profile.total_orders if profile else 0
        disputes = 0  # TODO: count disputes related to this farmer
        rating = profile.rating if profile else 5.0
    elif user.role == Role.TRANSPORT_PROVIDER:
        orders_completed = profile.total_deliveries if profile else 0
        disputes = 0
        rating = profile.rating if profile else 5.0
    else:
        orders_completed = 0
        disputes = 0
        rating = 5.0

    score = min(100, orders_completed * 2 + 20)  # dummy formula
    if score >= 80:
        band = 'excellent'
    elif score >= 50:
        band = 'good'
    elif score >= 20:
        band = 'fair'
    else:
        band = 'poor'

    return {
        'score': score,
        'score_band': band,
        'reason': f'Orders: {orders_completed}, Rating: {rating}, Disputes: {disputes}',
        'orders_completed': orders_completed,
        'disputes': disputes,
    }


def update_trust_score(user: User) -> TrustScore:
    """
    Recalculate and update the user's trust score based on current metrics.
    """
    trust = get_or_create_trust_score(user)
    data = calculate_trust_score(user)
    trust.score = data['score']
    trust.score_band = data['score_band']
    trust.reason = data['reason']
    trust.orders_completed = data.get('orders_completed', 0)
    trust.disputes = data.get('disputes', 0)
    trust.last_calculated = timezone.now()
    # verification_level is updated elsewhere (KYC)
    trust.save(update_fields=[
        'score', 'score_band', 'reason', 'orders_completed',
        'disputes', 'last_calculated'
    ])
    return trust