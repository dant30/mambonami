# django_admin/apps/logistics/services/fee_calculator.py
"""
Fee calculation service for dynamic delivery pricing.

Supports:
- Distance-based rates (per km, provider-specific)
- Weight-based penalties (excess capacity surcharge)
- Waiting time surcharge (with grace period)
- Rounding to nearest 5 KES for cash transactions
"""

from decimal import Decimal, ROUND_UP
from typing import Optional


def calculate_delivery_fee(
    distance_km: float,
    total_weight_kg: float,
    provider,  # TransportProviderProfile instance
    waiting_minutes: int = 0
) -> Decimal:
    """
    Calculate total delivery fee for a provider.
    
    Args:
        distance_km: Distance from pickup to delivery in kilometers
        total_weight_kg: Total weight of order items in kg
        provider: TransportProviderProfile instance
        waiting_minutes: Minutes waited (calculated later, used for surcharges)
    
    Returns:
        Decimal: Total fee rounded to nearest 5 KES
    
    Formula:
        fee = (distance * base_rate) + weight_penalty + waiting_surcharge
        rounded up to nearest 5 KES
    """
    fee = Decimal('0')
    
    # 1. Distance component (base rate)
    fee += Decimal(str(distance_km)) * provider.base_rate_per_km
    
    # 2. Weight excess penalty
    # If total weight exceeds provider's capacity, add surcharge
    if total_weight_kg > provider.capacity_kg:
        excess_kg = total_weight_kg - provider.capacity_kg
        # KES 10 per extra kilogram
        fee += Decimal(str(excess_kg)) * Decimal('10.00')
    
    # 3. Waiting surcharge (only if waiting_minutes > grace period)
    if waiting_minutes > provider.waiting_grace_minutes:
        extra_minutes = waiting_minutes - provider.waiting_grace_minutes
        fee += Decimal(str(extra_minutes)) * provider.waiting_rate_per_min
    
    # 4. Round up to nearest 5 KES (easier for cash transactions)
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


def get_default_rates_for_vehicle_type(vehicle_type: str) -> dict:
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
        },
        'pickup': {
            'base_rate_per_km': Decimal('45.00'),
            'waiting_grace_minutes': 20,
            'waiting_rate_per_min': Decimal('2.50'),
        },
        'van': {
            'base_rate_per_km': Decimal('50.00'),
            'waiting_grace_minutes': 20,
            'waiting_rate_per_min': Decimal('2.50'),
        },
        'lorry': {
            'base_rate_per_km': Decimal('75.00'),
            'waiting_grace_minutes': 30,
            'waiting_rate_per_min': Decimal('3.00'),
        },
    }
    
    return defaults.get(vehicle_type, defaults['motorcycle'])


def estimate_fee(
    distance_km: float,
    total_weight_kg: float,
    vehicle_type: str = 'motorcycle',
    capacity_kg: int = 100
) -> Decimal:
    """
    Estimate delivery fee without a provider instance (for frontend preview).
    
    Args:
        distance_km: Estimated distance
        total_weight_kg: Total weight
        vehicle_type: Vehicle type for default rates
        capacity_kg: Vehicle capacity in kg
    
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
            self.capacity_kg = capacity_kg
    
    provider = ProviderStub(vehicle_type, capacity_kg)
    return calculate_delivery_fee(distance_km, total_weight_kg, provider, waiting_minutes=0)
