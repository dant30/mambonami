# django_admin/apps/logistics/services/geolocation.py
# backend/django_admin/apps/logistics/services/geolocation.py
from math import radians, sin, cos, sqrt, asin

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

def estimate_delivery_fee(origin_lat: float, origin_lon: float, dest_lat: float, dest_lon: float, base_rate_per_km: float = 50.0) -> float:
    """
    Simple fee calculation based on distance.
    """
    distance = haversine(origin_lat, origin_lon, dest_lat, dest_lon)
    return distance * base_rate_per_km