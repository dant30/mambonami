# backend/django_admin/apps/logistics/services/geolocation.py
from math import radians, sin, cos, sqrt, asin
from typing import Optional, Tuple

def haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate the great-circle distance between two points in kilometers.
    """
    R = 6371  # Earth radius in km
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    return R * c


def estimate_delivery_fee(
    origin_lat: float,
    origin_lon: float,
    dest_lat: float,
    dest_lon: float,
    base_rate_per_km: float = 50.0
) -> float:
    """
    Simple fee calculation based on distance.
    """
    distance = haversine(origin_lat, origin_lon, dest_lat, dest_lon)
    return distance * base_rate_per_km


def is_within_geofence(
    lat: float,
    lon: float,
    target_lat: float,
    target_lon: float,
    radius_meters: float = 100.0
) -> bool:
    """
    Check if a point is within a geofence radius of a target location.
    
    Args:
        lat, lon: Current location
        target_lat, target_lon: Target location
        radius_meters: Radius in meters (default 100m)
    
    Returns:
        bool: True if within radius
    """
    distance_km = haversine(lat, lon, target_lat, target_lon)
    distance_meters = distance_km * 1000
    return distance_meters <= radius_meters


def parse_gps(gps_string: str) -> Optional[Tuple[float, float]]:
    """
    Parse a GPS string "lat,lng" into a tuple of floats.
    """
    if not gps_string:
        return None
    try:
        parts = gps_string.split(',')
        if len(parts) != 2:
            return None
        return (float(parts[0].strip()), float(parts[1].strip()))
    except (ValueError, AttributeError):
        return None


def format_gps(lat: float, lng: float) -> str:
    """Format GPS coordinates as "lat,lng" string."""
    return f"{lat:.6f},{lng:.6f}"


def get_eta_minutes(distance_km: float, average_speed_kmh: float = 40.0) -> int:
    """
    Calculate estimated time of arrival in minutes.
    
    Args:
        distance_km: Distance in kilometers
        average_speed_kmh: Average speed in km/h (default 40 km/h for Nairobi)
    
    Returns:
        int: Estimated minutes (minimum 5)
    """
    if distance_km <= 0:
        return 5
    hours = distance_km / average_speed_kmh
    minutes = int(hours * 60)
    return max(5, minutes)