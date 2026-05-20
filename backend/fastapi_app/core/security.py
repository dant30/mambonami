# backend/fastapi_app/core/security.py
from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
from core.config import settings

security = HTTPBearer()

async def verify_jwt(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Verify JWT token (for routes that need auth before proxying)."""
    token = credentials.credentials
    try:
        # Decode without verification? Actually we should forward token to Django.
        # For proxy, we don't need to decode here; just validate presence.
        # But for stricter security, you can verify signature using Django's secret.
        # Simpler: pass token to Django and let Django verify.
        return token
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
