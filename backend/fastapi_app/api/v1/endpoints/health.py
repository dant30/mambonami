# backend/fastapi_app/api/v1/endpoints/health.py
from fastapi import APIRouter, Depends, HTTPException, status
import httpx
from core.config import settings
from core.dependencies import get_http_client

router = APIRouter()

@router.get('/live')
async def liveness():
    """Kubernetes liveness probe."""
    return {"status": "alive"}

@router.get('/ready')
async def readiness(http_client: httpx.AsyncClient = Depends(get_http_client)):
    """Readiness probe: check if Django is reachable."""
    try:
        resp = await http_client.get(f"{settings.DJANGO_BASE_URL}/health/")
        if resp.status_code == 200:
            return {"status": "ready"}
    except Exception:
        pass
    raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail={"status": "not ready"})
