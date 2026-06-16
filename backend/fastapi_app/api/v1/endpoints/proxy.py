# backend/fastapi_app/api/v1/endpoints/proxy.py
from fastapi import APIRouter, Request, Response, Depends, HTTPException
import httpx
import logging
from core.config import settings
from core.dependencies import get_http_client

logger = logging.getLogger(__name__)
router = APIRouter()

@router.api_route("/{path:path}", methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD"])
async def proxy_request(
    request: Request,
    path: str,
    http_client: httpx.AsyncClient = Depends(get_http_client),
):
    """Proxy all requests to Django backend."""
    base_url = settings.DJANGO_BASE_URL.rstrip("/")
    normalized_path = path.lstrip("/")

    # Avoid duplicate API prefix if the Django base URL already includes /api.
    if base_url.endswith("/api") and normalized_path.startswith("api/"):
        normalized_path = normalized_path[len("api/"):]

    target_url = f"{base_url}/{normalized_path}"
    
    # Build headers, preserving all important ones from the request
    headers = dict(request.headers)
    headers.pop("host", None)
    
    body = await request.body()
    json_body = None
    if headers.get("content-type", "").startswith("application/json") and body:
        try:
            json_body = await request.json()
        except Exception:
            json_body = None

    logger.info(f"Proxying {request.method} {path} -> {target_url}")
    if request.method in {"POST", "PUT", "PATCH"}:
        # Log minimal request details at debug level to avoid leaking sensitive data
        if json_body is not None:
            logger.debug(f"Proxy JSON body length: {len(str(json_body))}")
        else:
            logger.debug(f"Proxy raw body length: {len(body)}")
        logger.debug(f"Proxy headers: content-type={headers.get('content-type')}, accept={headers.get('accept')}")

    try:
        response = await http_client.request(
            method=request.method,
            url=target_url,
            headers=headers,
            json=json_body if json_body is not None else None,
            content=None if json_body is not None else (body if body else None),
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
            'set-cookie',
        }

        headers_dict = {
            name: value
            for name, value in response.headers.items()
            if name.lower() not in excluded_headers
        }

        proxied_response = Response(
            content=response.content,
            status_code=response.status_code,
            headers=headers_dict,
        )

        # Preserve cookies from Django backend
        if hasattr(response.headers, 'raw'):
            from http.cookies import SimpleCookie

            for name, value in response.headers.raw:
                if isinstance(name, bytes):
                    name = name.decode('latin-1')
                if isinstance(value, bytes):
                    value = value.decode('latin-1')
                if name.lower() == 'set-cookie':
                    cookie = SimpleCookie()
                    cookie.load(value)
                    for cookie_name, morsel in cookie.items():
                        proxied_response.set_cookie(
                            cookie_name,
                            morsel.value,
                            path=morsel['path'] or '/',
                            domain=morsel['domain'] or None,
                            secure=bool(morsel['secure']),
                            httponly=bool(morsel['httponly']),
                            samesite=morsel['samesite'] or 'Lax',
                        )

        logger.info(f"Proxy response status: {response.status_code}")
        if response.status_code >= 400:
            logger.error(f"Proxy error response body: {response.text[:500]}")
        return proxied_response
    except httpx.RequestError as e:
        raise HTTPException(status_code=502, detail=f"Backend unreachable: {str(e)}")
