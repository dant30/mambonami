# backend/django_admin/apps/logistics/services/otp_service.py
import random
from django.utils import timezone
from datetime import timedelta
from decimal import Decimal
from ..models import Trip, TripStatus
import logging

logger = logging.getLogger(__name__)


def generate_otp(trip: Trip) -> str:
    """
    Generate a 6-digit OTP and set expiry (5 minutes).
    Hashes the OTP before storing (using Django's make_password).
    """
    otp = f'{random.randint(0, 999999):06d}'
    
    # Use Django's password hashing for OTP
    from django.contrib.auth.hashers import make_password
    trip.otp_hash = make_password(otp)
    trip.otp_expires_at = timezone.now() + timedelta(minutes=5)
    trip.otp_attempts = 0
    trip.save(update_fields=['otp_hash', 'otp_expires_at', 'otp_attempts'])
    
    logger.info(f"OTP generated for trip {trip.id}, expires at {trip.otp_expires_at}")
    
    # Return the raw OTP for sending via notification
    return otp


def verify_otp(trip: Trip, provided_otp: str, complete_delivery: bool = True) -> bool:
    """
    Validate OTP using Django's check_password (hashed comparison).
    Returns True if valid. By default, marks trip as delivered; callers that
    must persist proof before completing delivery can defer that transition.
    
    Handles:
    - Expired OTP
    - Max attempts (3)
    - Correct OTP → complete delivery
    """
    from django.contrib.auth.hashers import check_password
    
    # 1. Check if OTP exists
    if not trip.otp_hash:
        logger.warning(f"OTP verification failed: no OTP set for trip {trip.id}")
        return False
    
    # 2. Check expiry
    if timezone.now() > trip.otp_expires_at:
        logger.warning(f"OTP verification failed: OTP expired for trip {trip.id}")
        trip.status = TripStatus.FAILED
        trip.failure_reason = 'OTP expired'
        trip.failed_at = timezone.now()
        trip.save(update_fields=['status', 'failure_reason', 'failed_at'])
        return False
    
    # 3. Check attempts
    if trip.otp_attempts >= 3:
        logger.warning(f"OTP verification failed: max attempts exceeded for trip {trip.id}")
        trip.status = TripStatus.FAILED
        trip.failure_reason = 'Max OTP attempts exceeded'
        trip.failed_at = timezone.now()
        trip.save(update_fields=['status', 'failure_reason', 'failed_at'])
        return False
    
    # 4. Verify OTP (hashed comparison)
    if not check_password(provided_otp, trip.otp_hash):
        trip.otp_attempts += 1
        trip.save(update_fields=['otp_attempts'])
        logger.info(f"OTP verification failed: incorrect OTP for trip {trip.id} (attempt {trip.otp_attempts}/3)")
        return False
    
    # 5. OTP is valid. The caller may defer completion until proof is stored.
    if not complete_delivery:
        return True

    trip.status = TripStatus.DELIVERED
    trip.completed_at = timezone.now()
    trip.otp_hash = ''  # Clear OTP after use (security)
    trip.otp_expires_at = None
    trip.save(update_fields=['status', 'completed_at', 'otp_hash', 'otp_expires_at'])
    
    logger.info(f"OTP verification successful: trip {trip.id} marked as delivered")
    return True


def regenerate_otp(trip: Trip) -> str:
    """
    Regenerate OTP for an existing trip (e.g., if previous expired).
    Resets attempts and extends expiry.
    """
    # Check if trip is in correct state
    if trip.status not in [TripStatus.ARRIVED_DELIVERY, TripStatus.OTP_PENDING]:
        raise ValueError(f"Cannot regenerate OTP: trip status is {trip.status}")
    
    # Generate new OTP
    otp = generate_otp(trip)
    
    # Reset attempts
    trip.otp_attempts = 0
    trip.save(update_fields=['otp_attempts'])
    
    logger.info(f"OTP regenerated for trip {trip.id}")
    return otp


def get_otp_remaining_attempts(trip: Trip) -> int:
    """Return remaining OTP attempts (max 3)."""
    return max(0, 3 - trip.otp_attempts)


def is_otp_valid(trip: Trip) -> bool:
    """Check if OTP is still valid (not expired, hashes exist)."""
    if not trip.otp_hash:
        return False
    if not trip.otp_expires_at:
        return False
    if timezone.now() > trip.otp_expires_at:
        return False
    return True


def clear_expired_otps() -> int:
    """Clear OTP hashes for expired trips. Called by Celery task."""
    from datetime import timedelta
    cutoff = timezone.now() - timedelta(minutes=5)
    expired_trips = Trip.objects.filter(
        otp_expires_at__lt=cutoff,
        status=TripStatus.OTP_PENDING
    )
    count = expired_trips.update(
        otp_hash='',
        otp_expires_at=None,
        failure_reason='OTP expired',
        failed_at=timezone.now(),
        status=TripStatus.FAILED,
    )
    if count > 0:
        logger.info(f"Cleared {count} expired OTPs and marked trips as failed")
    return count