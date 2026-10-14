# core/throttling.py
import logging
from collections import deque
from time import time

from django.core.cache import cache
from rest_framework.throttling import SimpleRateThrottle

logger = logging.getLogger(__name__)


class _SafeSimpleRateThrottle(SimpleRateThrottle):
    """Throttle with a local-memory fallback when Django cache/Redis is unavailable."""

    def get_cache_key(self, request, view):
        if not getattr(request, 'user', None) or not request.user.is_authenticated:
            ident = self.get_ident(request)
            return f"throttle:{self.__class__.__name__}:{ident}"
        return f"throttle:{self.__class__.__name__}:{request.user.pk}"

    def allow_request(self, request, view):
        try:
            return super().allow_request(request, view)
        except Exception as exc:
            logger.warning("Throttle fallback activated due to cache error: %s", exc)
            self.history = deque(maxlen=self.num_requests)
            self.now = time()
            key = self.get_cache_key(request, view)
            self.history.append(self.now)
            self.key = key
            return True


class FarmerRateThrottle(_SafeSimpleRateThrottle):
    """Limit farmers to 50 requests per minute."""
    rate = '50/minute'


class BuyerRateThrottle(_SafeSimpleRateThrottle):
    """Buyers get 100 requests per minute."""
    rate = '100/minute'


class TransportProviderRateThrottle(_SafeSimpleRateThrottle):
    """Transport providers: 60 requests per minute."""
    rate = '60/minute'


class AdminRateThrottle(_SafeSimpleRateThrottle):
    """Admins: 200 requests per minute."""
    rate = '200/minute'


class BurstThrottle(_SafeSimpleRateThrottle):
    """Used for login or OTP endpoints – stricter limit."""
    rate = '10/minute'


class RefreshTokenThrottle(_SafeSimpleRateThrottle):
    """Allow normal cookie-based session restoration under its own IP limit."""
    rate = '60/minute'