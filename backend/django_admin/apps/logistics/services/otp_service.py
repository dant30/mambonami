# django_admin/apps/logistics/services/otp_service.py
# backend/django_admin/apps/logistics/services/otp_service.py
import random
from django.utils import timezone
from datetime import timedelta
from ..models import Trip

def generate_otp(trip: Trip) -> str:
    """Generate a 6-digit OTP and set expiry (5 minutes)."""
    otp = str(random.randint(100000, 999999))
    trip.otp_code = otp
    trip.otp_expires_at = timezone.now() + timedelta(minutes=5)
    trip.otp_attempts = 0
    trip.save(update_fields=['otp_code', 'otp_expires_at', 'otp_attempts'])
    return otp

def verify_otp(trip: Trip, provided_otp: str) -> bool:
    """Validate OTP. Returns True if valid and marks trip as delivered."""
    if not trip.otp_code:
        return False
    if timezone.now() > trip.otp_expires_at:
        return False
    if trip.otp_attempts >= 3:
        return False
    if trip.otp_code != provided_otp:
        trip.otp_attempts += 1
        trip.save(update_fields=['otp_attempts'])
        return False
    # OTP valid
    trip.status = 'delivered'
    trip.delivered_at = timezone.now()
    trip.otp_code = ''  # clear after use
    trip.save(update_fields=['status', 'delivered_at', 'otp_code'])
    return True