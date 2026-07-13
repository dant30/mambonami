# backend/django_admin/apps/logistics/tasks.py
from celery import shared_task
from django.utils import timezone
from datetime import timedelta
from .models import Trip, TripStatus
from apps.users.models import TransportProviderProfile


# ── Existing tasks ──

@shared_task
def auto_cancel_stale_trips():
    """
    Cancel trips that are still 'offered' or 'accepted' but not picked up after 2 hours.
    Also cancel trips that are 'en_route_pickup' for over 45 minutes.
    """
    cutoff_offered = timezone.now() - timedelta(hours=2)
    stale_offered = Trip.objects.filter(
        status__in=[TripStatus.OFFERED, TripStatus.ACCEPTED],
        created_at__lt=cutoff_offered
    )
    count_offered = stale_offered.update(
        status=TripStatus.CANCELLED,
        cancelled_at=timezone.now(),
        cancel_reason='Auto-cancelled: no pickup within 2 hours'
    )
    
    cutoff_en_route = timezone.now() - timedelta(minutes=45)
    stale_en_route = Trip.objects.filter(
        status=TripStatus.EN_ROUTE_PICKUP,
        started_navigation_pickup__lt=cutoff_en_route
    )
    count_en_route = stale_en_route.update(
        status=TripStatus.CANCELLED,
        cancelled_at=timezone.now(),
        cancel_reason='Auto-cancelled: provider did not arrive within 45 minutes'
    )
    
    return f"Cancelled {count_offered} stale trips (offered/accepted) and {count_en_route} en-route trips."


@shared_task
def cleanup_expired_otp():
    """Clear OTP hashes for trips older than 30 minutes after expiry."""
    expired = Trip.objects.filter(
        otp_expires_at__lt=timezone.now()
    ).exclude(otp_hash='')
    count = expired.update(otp_hash='')
    return f"Cleared {count} expired OTPs."


@shared_task
def update_provider_reliability_metrics(provider_id=None):
    """
    Recompute acceptance_rate, completion_rate, on_time_percentage for a specific provider,
    or all providers if provider_id is None.
    Should be scheduled daily or after each trip completion.
    """
    if provider_id:
        providers = TransportProviderProfile.objects.filter(id=provider_id)
    else:
        providers = TransportProviderProfile.objects.all()
    
    updated = 0
    for provider in providers:
        provider.update_reliability_metrics()
        updated += 1
    
    return f"Updated reliability metrics for {updated} provider(s)."


@shared_task
def auto_escalate_disputed_trips():
    """
    Escalate trips that have been disputed for more than 48 hours without admin action.
    """
    cutoff = timezone.now() - timedelta(hours=48)
    disputed = Trip.objects.filter(
        status=TripStatus.DISPUTED,
        updated_at__lt=cutoff
    )
    # Just log for now; could send admin notification
    count = disputed.count()
    # Send admin notification
    # from apps.notifications.services.email import send_admin_alert
    # send_admin_alert.delay(f"{count} trips disputed over 48 hours")
    return f"Found {count} disputed trips older than 48 hours."


@shared_task
def update_trip_eta(trip_id):
    """
    Recalculate ETA for a trip based on current location.
    Can be called periodically for active trips.
    """
    from .services.geolocation import haversine
    
    try:
        trip = Trip.objects.get(id=trip_id)
    except Trip.DoesNotExist:
        return None
    
    if trip.status in [TripStatus.EN_ROUTE_DELIVERY, TripStatus.ARRIVED_DELIVERY]:
        if trip.current_lat and trip.current_lng and trip.delivery_lat and trip.delivery_lng:
            try:
                distance = haversine(
                    float(trip.current_lat), float(trip.current_lng),
                    float(trip.delivery_lat), float(trip.delivery_lng)
                )
                # Average speed 40 km/h
                eta_minutes = max(5, int((distance / 40) * 60))
                trip.eta_minutes = eta_minutes
                trip.save(update_fields=['eta_minutes'])
                return eta_minutes
            except:
                pass
    return None


@shared_task
def cleanup_old_location_pings(days=7):
    """
    Delete location pings older than `days` to save storage.
    """
    from .models import TripLocationPing
    cutoff = timezone.now() - timedelta(days=days)
    count, _ = TripLocationPing.objects.filter(timestamp__lt=cutoff).delete()
    return f"Deleted {count} location pings older than {days} days."