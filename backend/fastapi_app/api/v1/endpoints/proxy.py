# backend/fastapi_app/api/v1/endpoints/proxy.py
from fastapi import APIRouter, Request, Response, Depends, HTTPException
import httpx
from core.config import settings
from core.dependencies import get_http_client

router = APIRouter()

@router.api_route("/{path:path}", methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD"])
async def proxy_request(
    request: Request,
    path: str,
    http_client: httpx.AsyncClient = Depends(get_http_client),
):
    """Proxy all requests to Django backend."""
    target_url = f"{settings.DJANGO_BASE_URL}/{path}"
    headers = dict(request.headers)
    headers.pop("host", None)
    body = await request.body()

    try:
        response = await http_client.request(
            method=request.method,
            url=target_url,
            headers=headers,
            content=body,
            params=request.query_params,
            follow_redirects=False,
        )

        excluded_headers = {
            'connection',
            'keep-alive',
            'proxy-authenticate',
            'proxy-authorization',
            'te',
            'trailers',
            'transfer-encoding',
            'upgrade',
            'content-length',
        }

        response_headers = []
        if hasattr(response.headers, 'multi_items'):
            for name, value in response.headers.multi_items():
                if name.lower() not in excluded_headers:
                    response_headers.append((name, value))
        elif hasattr(response, 'raw'):
            for name, value in response.raw:
                if isinstance(name, bytes):
                    name = name.decode('latin-1')
                if isinstance(value, bytes):
                    value = value.decode('latin-1')
                if name.lower() not in excluded_headers:
                    response_headers.append((name, value))
        else:
            for name, value in response.headers.items():
                if name.lower() not in excluded_headers:
                    response_headers.append((name, value))

        return Response(
            content=response.content,
            status_code=response.status_code,
            headers=response_headers,
        )
    except httpx.RequestError as e:
        raise HTTPException(status_code=502, detail=f"Backend unreachable: {str(e)}")
