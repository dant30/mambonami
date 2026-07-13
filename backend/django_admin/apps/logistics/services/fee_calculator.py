# backend/django_admin/apps/logistics/services/fee_calculator.py
"""
Fee calculation service for dynamic delivery pricing.

Supports:
- Distance-based rates (per km, provider-specific)
- Weight-based penalties (excess capacity surcharge)
- Waiting time surcharge (with grace period)
- Surge pricing (peak hours, demand)
- Rounding to nearest 5 KES for cash transactions
"""

from decimal import Decimal, ROUND_UP, ROUND_HALF_UP
from typing import Optional, Dict, Any
from django.utils import timezone


def calculate_delivery_fee(
    distance_km: float,
    total_weight_kg: float,
    provider,  # TransportProviderProfile instance
    waiting_minutes: int = 0,
    is_peak_hour: bool = False,
) -> Decimal:
    """
    Calculate total delivery fee for a provider.
    
    Args:
        distance_km: Distance from pickup to delivery in kilometers
        total_weight_kg: Total weight of order items in kg
        provider: TransportProviderProfile instance
        waiting_minutes: Minutes waited (calculated later, used for surcharges)
        is_peak_hour: Whether current time is peak hour (surge pricing)
    
    Returns:
        Decimal: Total fee rounded to nearest 5 KES
    
    Formula:
        fee = (distance * base_rate) + weight_penalty + waiting_surcharge + surge
        rounded up to nearest 5 KES
    """
    fee = Decimal('0')
    
    # 1. Distance component (base rate)
    fee += Decimal(str(distance_km)) * provider.base_rate_per_km
    
    # 2. Weight excess penalty
    # If total weight exceeds provider's capacity, add surcharge
    if total_weight_kg > provider.capacity_kg:
        excess_kg = total_weight_kg - provider.capacity_kg
        # KES 10 per extra kilogram (configurable)
        fee += Decimal(str(excess_kg)) * Decimal('10.00')
    
    # 3. Waiting surcharge (only if waiting_minutes > grace period)
    if waiting_minutes > provider.waiting_grace_minutes:
        extra_minutes = waiting_minutes - provider.waiting_grace_minutes
        fee += Decimal(str(extra_minutes)) * provider.waiting_rate_per_min
    
    # 4. Surge pricing (1.5x multiplier during peak hours)
    if is_peak_hour:
        fee = fee * Decimal('1.5')
    
    # 5. Round up to nearest 5 KES (easier for cash transactions)
    fee_rounded = (fee / Decimal('5')).quantize(Decimal('1'), rounding=ROUND_UP) * Decimal('5')
    
    return fee_rounded


def calculate_waiting_surcharge(
    provider,
    waiting_minutes: int
) -> Decimal:
    """
    Calculate surcharge for waiting time beyond grace period.
    
    Args:
        provider: TransportProviderProfile instance
        waiting_minutes: Minutes waited
    
    Returns:
        Decimal: Surcharge amount (0 if within grace period)
    """
    if waiting_minutes <= provider.waiting_grace_minutes:
        return Decimal('0.00')
    
    extra_minutes = waiting_minutes - provider.waiting_grace_minutes
    surcharge = Decimal(str(extra_minutes)) * provider.waiting_rate_per_min
    
    return surcharge.quantize(Decimal('0.01'), rounding=ROUND_UP)


def get_default_rates_for_vehicle_type(vehicle_type: str) -> Dict[str, Any]:
    """
    Get default rate parameters for vehicle type (MVP defaults).
    
    Used during provider registration or admin setup.
    
    Args:
        vehicle_type: One of 'motorcycle', 'pickup', 'van', 'lorry'
    
    Returns:
        dict with base_rate_per_km, waiting_grace_minutes, waiting_rate_per_min
    """
    defaults = {
        'motorcycle': {
            'base_rate_per_km': Decimal('25.00'),
            'waiting_grace_minutes': 10,
            'waiting_rate_per_min': Decimal('2.00'),
            'capacity_kg': 100,
        },
        'pickup': {
            'base_rate_per_km': Decimal('45.00'),
            'waiting_grace_minutes': 20,
            'waiting_rate_per_min': Decimal('2.50'),
            'capacity_kg': 500,
        },
        'van': {
            'base_rate_per_km': Decimal('50.00'),
            'waiting_grace_minutes': 20,
            'waiting_rate_per_min': Decimal('2.50'),
            'capacity_kg': 800,
        },
        'lorry': {
            'base_rate_per_km': Decimal('75.00'),
            'waiting_grace_minutes': 30,
            'waiting_rate_per_min': Decimal('3.00'),
            'capacity_kg': 2000,
        },
    }
    
    return defaults.get(vehicle_type, defaults['motorcycle'])


def estimate_fee(
    distance_km: float,
    total_weight_kg: float,
    vehicle_type: str = 'motorcycle',
    capacity_kg: int = None,
    is_peak_hour: bool = False
) -> Decimal:
    """
    Estimate delivery fee without a provider instance (for frontend preview).
    
    Args:
        distance_km: Estimated distance
        total_weight_kg: Total weight
        vehicle_type: Vehicle type for default rates
        capacity_kg: Vehicle capacity in kg (overrides default)
        is_peak_hour: Whether peak hour surcharge applies
    
    Returns:
        Decimal: Estimated fee
    """
    # Create a minimal provider-like object for calculation
    class ProviderStub:
        def __init__(self, vehicle_type, capacity_kg):
            rates = get_default_rates_for_vehicle_type(vehicle_type)
            self.base_rate_per_km = rates['base_rate_per_km']
            self.waiting_grace_minutes = rates['waiting_grace_minutes']
            self.waiting_rate_per_min = rates['waiting_rate_per_min']
            self.capacity_kg = capacity_kg or rates['capacity_kg']
    
    provider = ProviderStub(vehicle_type, capacity_kg)
    return calculate_delivery_fee(
        distance_km, total_weight_kg, provider,
        waiting_minutes=0, is_peak_hour=is_peak_hour
    )


def is_peak_hour() -> bool:
    """
    Determine if current time is peak hour (surge pricing).
    
    Peak hours:
    - Weekdays: 7-9 AM, 5-7 PM
    - Weekends: 10 AM - 2 PM
    """
    now = timezone.now()
    hour = now.hour
    is_weekday = now.weekday() < 5  # Monday=0, Sunday=6
    
    if is_weekday:
        return (7 <= hour <= 9) or (17 <= hour <= 19)
    else:
        return 10 <= hour <= 14


def calculate_total_for_buyer(
    order,
    provider,
    distance_km: float,
    waiting_minutes: int = 0
) -> Dict[str, Decimal]:
    """
    Calculate full fee breakdown for an order.
    
    Returns:
        dict with: base_fee, distance_fee, weight_fee, waiting_fee,
                   surge_fee, commission, provider_payout, platform_fee, buyer_total
    """
    from decimal import Decimal
    
    # Calculate base fee
    base_fee = Decimal(str(distance_km)) * provider.base_rate_per_km
    
    # Weight penalty
    weight_fee = Decimal('0')
    if order.total_weight_kg > provider.capacity_kg:
        excess_kg = order.total_weight_kg - provider.capacity_kg
        weight_fee = Decimal(str(excess_kg)) * Decimal('10.00')
    
    # Waiting fee
    waiting_fee = Decimal('0')
    if waiting_minutes > provider.waiting_grace_minutes:
        extra_minutes = waiting_minutes - provider.waiting_grace_minutes
        waiting_fee = Decimal(str(extra_minutes)) * provider.waiting_rate_per_min
    
    # Surge fee
    peak = is_peak_hour()
    surge_fee = Decimal('0')
    if peak:
        surge_multiplier = Decimal('0.5')  # 50% surcharge
        surge_fee = (base_fee + weight_fee + waiting_fee) * surge_multiplier
    
    # Total before commission
    buyer_total = base_fee + weight_fee + waiting_fee + surge_fee
    buyer_total = (buyer_total / Decimal('5')).quantize(Decimal('1'), rounding=ROUND_UP) * Decimal('5')
    
    # Commission (20% of buyer_total)
    commission = buyer_total * Decimal('0.20')
    platform_fee = commission
    provider_payout = buyer_total - commission
    
    return {
        'base_fee': base_fee.quantize(Decimal('0.01')),
        'distance_fee': base_fee.quantize(Decimal('0.01')),  # alias
        'weight_fee': weight_fee.quantize(Decimal('0.01')),
        'waiting_fee': waiting_fee.quantize(Decimal('0.01')),
        'surge_fee': surge_fee.quantize(Decimal('0.01')),
        'commission': commission.quantize(Decimal('0.01')),
        'provider_payout': provider_payout.quantize(Decimal('0.01')),
        'platform_fee': platform_fee.quantize(Decimal('0.01')),
        'buyer_total': buyer_total.quantize(Decimal('0.01')),
        'is_peak_hour': peak,
    }