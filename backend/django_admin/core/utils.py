# core/utils.py
import random
import string
from decimal import Decimal
from typing import Dict, Any

def generate_otp(length: int = 4) -> str:
    """Generate a numeric OTP of given length."""
    return ''.join(random.choices(string.digits, k=length))

def generate_uuid_short() -> str:
    """Generate a short UUID (first 8 characters)."""
    import uuid
    return str(uuid.uuid4()).replace('-', '')[:8]

def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate Haversine distance between two GPS points in kilometres.
    """
    from math import radians, sin, cos, sqrt, asin
    R = 6371  # Earth radius in km
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    return R * c

def round_price(value: Decimal) -> Decimal:
    """Round price to two decimal places."""
    return value.quantize(Decimal('0.01'))

def parse_gps(gps_string: str) -> Dict[str, float]:
    """
    Parse "lat,lng" string into a dictionary.
    Raises ValueError if invalid.
    """
    lat_str, lng_str = gps_string.split(',')
    return {'lat': float(lat_str.strip()), 'lng': float(lng_str.strip())}