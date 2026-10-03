# backend/django_admin/apps/logistics/services/matching.py
import logging
from decimal import Decimal
from typing import TYPE_CHECKING, List, Tuple, Optional
from django.utils import timezone
from django.db.models import Q, F
from django.db import transaction
from apps.users.models import TransportProviderProfile
from apps.orders.models import Order
from apps.orders.services.state_machine import OrderStateMachine
from core.cache import RedisCache
from .geolocation import haversine, parse_gps
from .fee_calculator import calculate_delivery_fee, calculate_total_for_buyer, is_peak_hour

logger = logging.getLogger(__name__)

if TYPE_CHECKING:
    from ..models import Trip


def find_eligible_providers(
    order: Order,
    limit: int = 10,
    max_distance_km: float = 20.0
) -> List[Tuple[TransportProviderProfile, Decimal, float]]:
    """
    Find providers eligible for order based on:
    - Approval and payment status
    - Vehicle capacity (must >= order weight)
    - Distance to pickup (prefer closer)
    - Rating (sorted descending)
    
    Returns: List of (provider, estimated_fee, distance) tuples sorted by fee
    """
    if order.status != 'paid_escrow' or not OrderStateMachine.has_successful_payment(order):
        logger.warning('Order %s is not paid; transport matching is blocked', order.id)
        return []
    if not order.are_all_farmers_ready():
        logger.warning('Order %s still has farmer items not ready for pickup', order.id)
        return []
    if not order.total_weight_kg or order.total_weight_kg <= 0:
        logger.warning(f"Order {order.id} has no weight info")
        return []
    
    # Get pickup location
    pickup_location = get_pickup_location_for_order(order)
    if not pickup_location:
        logger.warning(f"Order {order.id} has no pickup location")
        return []
    
    pickup_lat, pickup_lng = pickup_location
    
    # Query eligible providers (must have capacity)
    eligible_providers = TransportProviderProfile.objects.filter(
        is_approved=True,
        deposit_paid=True,
        user__is_active=True,
        capacity_kg__gte=order.total_weight_kg,  # Filter by capacity
    ).select_related('user').order_by('-rating')
    
    result = []
    for provider in eligible_providers:
        try:
            # Calculate distance from provider's stored location to pickup
            # If provider has no stored location, use a default radius
            # For MVP, we skip distance filtering if no provider location
            provider_location = get_provider_location(provider)
            if provider_location:
                distance = haversine(
                    pickup_lat, pickup_lng,
                    provider_location[0], provider_location[1]
                )
                if distance > max_distance_km:
                    continue  # Skip providers too far
            else:
                # If provider location unknown, still consider (use 0 distance)
                distance = 0.0
            
            # Estimate fee (no waiting time at this stage)
            estimated_fee = calculate_delivery_fee(
                distance,
                float(order.total_weight_kg),
                provider,
                waiting_minutes=0,
                is_peak_hour=is_peak_hour()
            )
            
            result.append((provider, estimated_fee, distance))
        except Exception as e:
            logger.error(f"Error calculating fee for provider {provider.id}: {e}")
            continue
    
    # Sort by fee (ascending), then by distance
    result.sort(key=lambda x: (x[1], x[2]))
    
    return result[:limit]


def get_pickup_location_for_order(order: Order) -> Optional[Tuple[float, float]]:
    """
    Extract pickup GPS from order.
    
    Strategy:
    1. Try to get pickup from products (new model has pickup_lat/pickup_lng)
    2. Fallback to farmer's farm_gps
    3. Use average of all farmers' locations
    """
    try:
        # Strategy 1: Get from first sub_order's product pickup location
        sub_order = order.sub_orders.first()
        if sub_order:
            order_item = sub_order.items.first()
            if order_item and order_item.product:
                product = order_item.product
                if product.pickup_lat and product.pickup_lng:
                    return (float(product.pickup_lat), float(product.pickup_lng))
            
            # Strategy 2: Fallback to farmer's farm_gps
            farmer = sub_order.farmer
            if farmer.farm_gps:
                location = parse_gps(farmer.farm_gps)
                if location:
                    return location
        
        # Strategy 3: Average all farmers' locations
        return get_average_pickup_location(order)
    
    except (ValueError, AttributeError, IndexError) as e:
        logger.warning(f"Error extracting pickup location for order {order.id}: {e}")
    
    return None


def get_average_pickup_location(order: Order) -> Optional[Tuple[float, float]]:
    """Get average pickup location from all farmers in order."""
    try:
        lats, lngs = [], []
        
        for sub_order in order.sub_orders.all():
            farmer = sub_order.farmer
            if farmer.farm_gps:
                location = parse_gps(farmer.farm_gps)
                if location:
                    lats.append(location[0])
                    lngs.append(location[1])
            else:
                # Try to get from product
                product = sub_order.items.first()
                if product and product.product.pickup_lat and product.product.pickup_lng:
                    lats.append(float(product.product.pickup_lat))
                    lngs.append(float(product.product.pickup_lng))
        
        if lats and lngs:
            avg_lat = sum(lats) / len(lats)
            avg_lng = sum(lngs) / len(lngs)
            return (avg_lat, avg_lng)
    except Exception as e:
        logger.warning(f"Error calculating average pickup location for order {order.id}: {e}")
    
    return None


def get_provider_location(provider: TransportProviderProfile) -> Optional[Tuple[float, float]]:
    """Get stored location for a provider (if available)."""
    # Provider may have a home/base location stored
    # For MVP, we can use the last known trip pickup location
    # or a stored home location field (to be added)
    return None  # Placeholder for now


def suggest_vehicle_types(total_weight_kg: float) -> List[str]:
    """Suggest vehicle types based on total weight."""
    if total_weight_kg <= 50:
        return ['motorcycle']
    elif total_weight_kg <= 500:
        return ['motorcycle', 'pickup', 'van']
    else:
        return ['pickup', 'lorry', 'van']


def assign_provider_to_order(
    order: Order,
    provider: TransportProviderProfile
) -> 'Trip':
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
    from ..models import Trip, TripStatus

    with transaction.atomic():
        order = Order.objects.select_for_update().get(pk=order.pk)
        if order.status != 'paid_escrow' or not OrderStateMachine.has_successful_payment(order):
            raise ValueError('A successfully paid order is required before assigning transport.')
        if not order.are_all_farmers_ready():
            raise ValueError('All farmer suborders must be ready before assigning transport.')
    
    # Calculate delivery fee
    pickup_location = get_pickup_location_for_order(order)
    if not pickup_location:
        logger.error(f"Cannot assign provider to order {order.id}: no pickup location")
        raise ValueError("Order has no pickup location")
    
    pickup_lat, pickup_lng = pickup_location
    
    delivery_location = (float(order.delivery_lat), float(order.delivery_lng))
    distance_km = haversine(
        pickup_lat, pickup_lng,
        delivery_location[0], delivery_location[1]
    )
    
    # Get full fee breakdown
    fee_breakdown = calculate_total_for_buyer(
        order, provider, distance_km, waiting_minutes=0
    )
    
    with transaction.atomic():
        # Create Trip with 'accepted' status
        trip = Trip.objects.create(
            order=order,
            provider=provider,
            status=TripStatus.ACCEPTED,
            accepted_at=timezone.now(),
            offered_at=timezone.now(),
            pickup_lat=Decimal(str(pickup_lat)),
            pickup_lng=Decimal(str(pickup_lng)),
            delivery_lat=order.delivery_lat,
            delivery_lng=order.delivery_lng,
            straight_line_km=Decimal(str(distance_km)),
            eta_minutes=max(10, int((distance_km / 40) * 60)),
            # Fee breakdown
            base_fee=fee_breakdown['base_fee'],
            distance_fee=fee_breakdown['distance_fee'],
            weight_fee=fee_breakdown['weight_fee'],
            waiting_fee=fee_breakdown['waiting_fee'],
            surge_fee=fee_breakdown['surge_fee'],
            commission=fee_breakdown['commission'],
            provider_payout=fee_breakdown['provider_payout'],
            platform_fee=fee_breakdown['platform_fee'],
            buyer_total=fee_breakdown['buyer_total'],
            # Legacy fields
            agreed_fee=fee_breakdown['buyer_total'],
            waiting_surcharge=Decimal('0'),
            # Vehicle snapshot
            vehicle_type=provider.vehicle_type,
            vehicle_plate=provider.license_plate,
            # Device info (will be updated later)
            accepted_device='',
            ip_address='',
        )
        
        # The buyer has already paid; keep the order's charged total immutable.
        order.assigned_provider = provider
        order.status = 'transport_assigned'
        order.save(update_fields=['assigned_provider', 'status'])
        
        # Update provider's total deliveries (incremented on completion)
        # provider.total_deliveries is updated via signal on completion
        
        logger.info(
            f"Assigned provider {provider.id} to order {order.id} "
            f"with fee KES {fee_breakdown['buyer_total']} "
            f"(distance: {distance_km:.1f}km, provider payout: KES {fee_breakdown['provider_payout']})"
        )
        
        # Invalidate cache
        RedisCache.delete(f'available_providers:{order.id}')
        
        return trip


def get_order_availability(order: Order) -> dict:
    """
    Check if an order can be assigned to a transport provider.
    
    Returns:
        dict with: available, reason, suggested_vehicle
    """
    issues = []
    
    # Check if order has pickup location
    if not get_pickup_location_for_order(order):
        issues.append('No pickup location set')
    
    # Check if order has delivery location
    if not order.delivery_lat or not order.delivery_lng:
        issues.append('No delivery location set')
    
    # Check if order has weight info
    if not order.total_weight_kg or order.total_weight_kg <= 0:
        issues.append('No weight information')
    
    # Check if order already has a trip
    if hasattr(order, 'trip') and order.trip and order.trip.status != 'cancelled':
        issues.append('Trip already exists')
    
    # Check if order is in a valid state
    if order.status != 'paid_escrow':
        issues.append(f'Order status is {order.status}, expected paid_escrow')
    
    # Suggest vehicle type
    suggested_vehicle = suggest_vehicle_types(
        float(order.total_weight_kg) if order.total_weight_kg else 0
    )[0]
    
    return {
        'available': len(issues) == 0,
        'issues': issues,
        'suggested_vehicle_type': suggested_vehicle,
    }