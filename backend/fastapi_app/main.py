# backend/fastapi_app/main.py
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from api.v1.endpoints.health import router as health_router
from api.v1.endpoints.metrics import router as metrics_router
from api.v1.endpoints.proxy import router as proxy_router
from core.logging import setup_logging
from core.config import settings
import time

setup_logging()

app = FastAPI(
    title="MAMBONAMI API Gateway",
    description="Routes traffic to Django backend, serves health/metrics",
    version="1.0.0",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Metrics middleware
@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start
    from api.v1.endpoints.metrics import REQUEST_COUNT, REQUEST_LATENCY
    REQUEST_COUNT.labels(method=request.method, endpoint=request.url.path).inc()
    REQUEST_LATENCY.labels(method=request.method, endpoint=request.url.path).observe(duration)
    return response

# Include routers
app.include_router(health_router, prefix="", tags=["health"])
app.include_router(metrics_router, prefix="/metrics", tags=["metrics"])
app.include_router(proxy_router, prefix="", tags=["proxy"])

@app.get("/", include_in_schema=False)
async def root():
    return {"message": "MAMBONAMI API Gateway"}