# backend/fastapi_app/core/dependencies.py
from typing import Optional
from fastapi import Request
import httpx

async def get_http_client(request: Request) -> httpx.AsyncClient:
    """Return an HTTPX client for proxying requests to Django."""
    # Reuse client if exists, otherwise create
    if not hasattr(request.app.state, "http_client"):
        request.app.state.http_client = httpx.AsyncClient(timeout=30.0)
    return request.app.state.http_client
