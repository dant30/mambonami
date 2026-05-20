# core/cache.py
import pickle
from typing import Any, Optional
from django.core.cache import cache
from django.conf import settings

class RedisCache:
    """Helper for Redis operations with fallback to Django's local-memory cache."""
    
    @staticmethod
    def get(key: str, default: Any = None) -> Any:
        return cache.get(key, default)
    
    @staticmethod
    def set(key: str, value: Any, timeout: Optional[int] = None) -> None:
        cache.set(key, value, timeout=timeout or settings.CACHE_TTL)
    
    @staticmethod
    def delete(key: str) -> None:
        cache.delete(key)
    
    @staticmethod
    def exists(key: str) -> bool:
        return cache.has_key(key)  # type: ignore
    
    @staticmethod
    def incr(key: str, delta: int = 1) -> int:
        return cache.incr(key, delta)
    
    @staticmethod
    def set_many(mapping: dict, timeout: Optional[int] = None) -> None:
        cache.set_many(mapping, timeout=timeout or settings.CACHE_TTL)
    
    @staticmethod
    def get_many(keys: list) -> dict:
        return cache.get_many(keys)


# Convenience wrappers
def cache_otp(phone: str, otp: str, timeout: int = 300) -> None:
    """Store OTP in cache with a default 5‑minute expiry."""
    RedisCache.set(f"otp:{phone}", otp, timeout=timeout)

def get_otp(phone: str) -> Optional[str]:
    return RedisCache.get(f"otp:{phone}")

def delete_otp(phone: str) -> None:
    RedisCache.delete(f"otp:{phone}")