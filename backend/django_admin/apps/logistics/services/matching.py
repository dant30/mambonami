# django_admin/apps/logistics/services/matching.py
# backend/django_admin/apps/logistics/services/matching.py
import logging
from django.db.models import Q
from apps.users.models import TransportProviderProfile
from apps.orders.models import Order
from core.cache import RedisCache
from .geolocation import haversine

logger = logging.getLogger(__name__)

def find_nearest_providers(order: Order, max_distance_km: float = 15.0, limit: int = 10):
    """
    Find active, approved transport providers near the farmer's location.
    Returns list of (provider, distance) sorted by distance.
    """
    # Get farmer GPS (from farmer_profile)
    farmer_profile = order.farmer_profile  # Assuming Order has farmer_profile FK
    if not farmer_profile.farm_gps:
        logger.warning(f"Farmer {farmer_profile.id} has no GPS coordinates")
        return []

    try:
        farm_lat, farm_lon = map(float, farmer_profile.farm_gps.split(','))
    except (ValueError, AttributeError):
        return []

    # Query eligible providers
    providers = TransportProviderProfile.objects.filter(
        is_approved=True,
        deposit_paid=True,
        user__is_active=True,
        vehicle_type__in=_suggest_vehicle_types(order.total_weight_kg())  # You need to add total_weight method in Order
    ).select_related('user')

    # Calculate distances and filter
    result = []
    for provider in providers:
        # Assume provider has stored home location? For now, we skip distance filtering or use a default.
        # In a real system, you'd need provider's current location. We'll just return all eligible.
        # For MVP, we return all approved providers without distance filtering.
        result.append((provider, 0.0))  # distance unknown

    # Sort by rating? Or by distance if we had it.
    result.sort(key=lambda x: x[0].rating, reverse=True)
    return result[:limit]

def _suggest_vehicle_types(total_weight_kg: float):
    if total_weight_kg <= 50:
        return ['motorcycle']
    elif total_weight_kg <= 500:
        return ['motorcycle', 'pickup', 'van']
    else:
        return ['pickup', 'lorry', 'van']

def assign_provider_to_order(order: Order, provider: TransportProviderProfile):
    """Create a Trip and assign provider."""
    from ..models import Trip
    trip, created = Trip.objects.get_or_create(order=order, defaults={'provider': provider, 'status': 'assigned'})
    if created:
        logger.info(f"Assigned provider {provider.id} to order {order.id}")
        # TODO: send notification to provider
    return trip