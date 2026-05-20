# core/throttling.py
from rest_framework.throttling import UserRateThrottle

class FarmerRateThrottle(UserRateThrottle):
    """Limit farmers to 50 requests per minute."""
    rate = '50/minute'

class BuyerRateThrottle(UserRateThrottle):
    """Buyers get 100 requests per minute."""
    rate = '100/minute'

class TransportProviderRateThrottle(UserRateThrottle):
    """Transport providers: 60 requests per minute."""
    rate = '60/minute'

class AdminRateThrottle(UserRateThrottle):
    """Admins: 200 requests per minute."""
    rate = '200/minute'

class BurstThrottle(UserRateThrottle):
    """Used for login or OTP endpoints – stricter limit."""
    rate = '10/minute'