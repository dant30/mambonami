# backend/django_admin/apps/logistics/services/matching.py
import logging
from decimal import Decimal
from django.utils import timezone
from django.db.models import Q
from apps.users.models import TransportProviderProfile
from apps.orders.models import Order
from core.cache import RedisCache
from .geolocation import haversine
from .fee_calculator import calculate_delivery_fee

logger = logging.getLogger(__name__)

def find_eligible_providers(order: Order, limit: int = 10) -> list:
    """
    Find providers eligible for order based on:
    - Approval and payment status
    - Vehicle capacity (must >= order weight)
    - Rating (sorted descending)
    
    Returns: List of (provider, estimated_fee) tuples sorted by fee
    """
    if not order.total_weight_kg or order.total_weight_kg <= 0:
        logger.warning(f"Order {order.id} has no weight info")
        return []
    
    # Query eligible providers (must have capacity)
    eligible_providers = TransportProviderProfile.objects.filter(
        is_approved=True,
        deposit_paid=True,
        user__is_active=True,
        capacity_kg__gte=order.total_weight_kg,  # Filter by capacity
    ).select_related('user').order_by('-rating')
    
    # Calculate distances and fees
    pickup_location = get_pickup_location(order)
    delivery_location = (float(order.delivery_lat), float(order.delivery_lng))
    
    if not pickup_location:
        logger.warning(f"Order {order.id} has no pickup location")
        return []
    
    result = []
    for provider in eligible_providers:
        try:
            # Calculate distance (simplified: using order GPS as reference)
            distance = haversine(
                pickup_location[0], pickup_location[1],
                delivery_location[0], delivery_location[1]
            )
            
            # Estimate fee (no waiting time at this stage)
            estimated_fee = calculate_delivery_fee(
                distance,
                float(order.total_weight_kg),
                provider,
                waiting_minutes=0
            )
            
            result.append((provider, estimated_fee, distance))
        except Exception as e:
            logger.error(f"Error calculating fee for provider {provider.id}: {e}")
            continue
    
    # Sort by fee (ascending)
    result.sort(key=lambda x: x[1])
    
    return [(p, f) for p, f, d in result[:limit]]


def get_pickup_location(order: Order) -> tuple:
    """
    Extract pickup GPS from order.
    
    Strategy:
    1. Use first product's pickup_lat/pickup_lng from first sub_order
    2. Fallback to farmer's farm_gps
    
    Returns: (lat, lng) tuple or None
    """
    try:
        # Try to get first product's pickup location
        sub_order = order.sub_orders.first()
        if sub_order:
            order_item = sub_order.items.first()
            if order_item and order_item.product.pickup_lat and order_item.product.pickup_lng:
                return (
                    float(order_item.product.pickup_lat),
                    float(order_item.product.pickup_lng)
                )
            
            # Fallback to farmer's farm_gps
            if sub_order.farmer.farm_gps:
                lat, lng = map(float, sub_order.farmer.farm_gps.split(','))
                return (lat, lng)
    except (ValueError, AttributeError) as e:
        logger.warning(f"Error extracting pickup location for order {order.id}: {e}")
    
    return None


def get_average_pickup_location(order: Order) -> tuple:
    """
    Get average pickup location from all farmers in order.
    
    Returns: (avg_lat, avg_lng) tuple or None
    """
    try:
        lats, lngs = [], []
        
        for sub_order in order.sub_orders.all():
            location = get_pickup_location_for_farmer(sub_order.farmer)
            if location:
                lats.append(location[0])
                lngs.append(location[1])
        
        if lats and lngs:
            avg_lat = sum(lats) / len(lats)
            avg_lng = sum(lngs) / len(lngs)
            return (avg_lat, avg_lng)
    except Exception as e:
        logger.warning(f"Error calculating average pickup location for order {order.id}: {e}")
    
    return None


def get_pickup_location_for_farmer(farmer_profile) -> tuple:
    """Get pickup location for a specific farmer."""
    try:
        # Try to get first product's pickup location
        product = farmer_profile.products.first()
        if product and product.pickup_lat and product.pickup_lng:
            return (float(product.pickup_lat), float(product.pickup_lng))
        
        # Fallback to farm_gps
        if farmer_profile.farm_gps:
            lat, lng = map(float, farmer_profile.farm_gps.split(','))
            return (lat, lng)
    except (ValueError, AttributeError):
        pass
    
    return None


def _suggest_vehicle_types(total_weight_kg: float):
    if total_weight_kg <= 50:
        return ['motorcycle']
    elif total_weight_kg <= 500:
        return ['motorcycle', 'pickup', 'van']
    else:
        return ['pickup', 'lorry', 'van']


def assign_provider_to_order(order: Order, provider: TransportProviderProfile) -> 'Trip':
    """
    Create a Trip and assign provider to order (provider accepts the offer).
    
    Calculates delivery fee based on distance and weight.
    Sets trip status to 'accepted' and records acceptance time.
    
    Args:
        order: Order instance
        provider: TransportProviderProfile instance
    
    Returns:
        Trip instance
    """
    from ..models import Trip
    
    # Calculate delivery fee
    pickup_location = get_pickup_location(order)
    delivery_location = (float(order.delivery_lat), float(order.delivery_lng))
    
    if not pickup_location:
        logger.error(f"Cannot assign provider to order {order.id}: no pickup location")
        raise ValueError("Order has no pickup location")
    
    distance_km = haversine(
        pickup_location[0], pickup_location[1],
        delivery_location[0], delivery_location[1]
    )
    
    agreed_fee = calculate_delivery_fee(
        distance_km,
        float(order.total_weight_kg),
        provider,
        waiting_minutes=0
    )
    
    # Create or update Trip with status 'accepted'
    trip, created = Trip.objects.get_or_create(
        order=order,
        defaults={
            'provider': provider,
            'status': 'accepted',
            'agreed_fee': agreed_fee,
            'accepted_at': timezone.now(),
            'pickup_lat': Decimal(str(pickup_location[0])),
            'pickup_lng': Decimal(str(pickup_location[1])),
            'delivery_lat': order.delivery_lat,
            'delivery_lng': order.delivery_lng,
            'distance_km': Decimal(str(distance_km)),
        }
    )
    
    if not created:
        # If trip exists (e.g., was offered), update to accepted
        trip.provider = provider
        trip.status = 'accepted'
        trip.accepted_at = timezone.now()
        trip.agreed_fee = agreed_fee
        trip.pickup_lat = Decimal(str(pickup_location[0]))
        trip.pickup_lng = Decimal(str(pickup_location[1]))
        trip.delivery_lat = order.delivery_lat
        trip.delivery_lng = order.delivery_lng
        trip.distance_km = Decimal(str(distance_km))
        trip.save()
    
    # Update order status and assigned provider
    old_delivery_fee = order.delivery_fee or Decimal('0')
    order.delivery_fee = agreed_fee
    order.total_amount = order.total_amount - old_delivery_fee + agreed_fee
    order.assigned_provider = provider
    order.status = 'transport_assigned'
    order.save(update_fields=['delivery_fee', 'total_amount', 'assigned_provider', 'status'])
    
    logger.info(
        f"Assigned provider {provider.id} to order {order.id} "
        f"with fee KES {agreed_fee} (distance: {distance_km:.1f}km)"
    )
    # TODO: send notification to provider with fee details
    
    return trip