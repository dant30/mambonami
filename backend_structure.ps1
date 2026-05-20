# backend_structure.ps1
# Run this script from the 'mambonami' directory.
# It creates the complete backend (Django + FastAPI) structure,
# including GitHub workflows, extended core utilities, and all Django apps.

$base = ".\backend\django_admin"
$fastapiBase = ".\backend\fastapi_app"
$githubBase = ".\backend\.github"

Write-Host "Creating complete MAMBONAMI backend structure..." -ForegroundColor Green

# ----- Define all directories (relative to $base) -----
$directories = @(
    "requirements",
    "config\settings",
    "core\validators",
    "core\management\commands",
    "apps\users\models",
    "apps\users\serializers",
    "apps\users\services",
    "apps\users\views",
    "apps\users\tests",
    "apps\users\migrations",
    "apps\products\models",
    "apps\products\serializers",
    "apps\products\services",
    "apps\products\views",
    "apps\products\tests",
    "apps\products\migrations",
    "apps\orders\models",
    "apps\orders\serializers",
    "apps\orders\services",
    "apps\orders\views",
    "apps\orders\tests",
    "apps\orders\migrations",
    "apps\payments\models",
    "apps\payments\serializers",
    "apps\payments\services",
    "apps\payments\views",
    "apps\payments\tests",
    "apps\payments\migrations",
    "apps\paybill\models",
    "apps\paybill\serializers",
    "apps\paybill\services",
    "apps\paybill\views",
    "apps\paybill\tests",
    "apps\paybill\migrations",
    "apps\payouts\models",
    "apps\payouts\serializers",
    "apps\payouts\services",
    "apps\payouts\views",
    "apps\payouts\tests",
    "apps\payouts\migrations",
    "apps\logistics\models",
    "apps\logistics\serializers",
    "apps\logistics\services",
    "apps\logistics\views",
    "apps\logistics\tests",
    "apps\logistics\migrations",
    "apps\disputes\models",
    "apps\disputes\serializers",
    "apps\disputes\services",
    "apps\disputes\views",
    "apps\disputes\tests",
    "apps\disputes\migrations",
    "apps\notifications\models",
    "apps\notifications\serializers",
    "apps\notifications\services",
    "apps\notifications\views",
    "apps\notifications\tests",
    "apps\notifications\migrations",
    "apps\audit\models",
    "apps\audit\serializers",
    "apps\audit\services",
    "apps\audit\views",
    "apps\audit\tests",
    "apps\audit\migrations",
    "apps\analytics\models",
    "apps\analytics\serializers",
    "apps\analytics\services",
    "apps\analytics\views",
    "apps\analytics\tests",
    "apps\analytics\migrations",
    "static"
)

# Create Django directories
foreach ($dir in $directories) {
    $fullPath = Join-Path $base $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "Created: $fullPath" -ForegroundColor Cyan
    }
}

# Create FastAPI directories
$fastapiDirs = @(
    "api\v1\endpoints",
    "core",
    "models",
    "schemas",
    "services"
)
foreach ($dir in $fastapiDirs) {
    $fullPath = Join-Path $fastapiBase $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "Created: $fullPath" -ForegroundColor Cyan
    }
}

# Create GitHub workflows directory
$githubWorkflows = Join-Path $githubBase "workflows"
if (-not (Test-Path $githubWorkflows)) {
    New-Item -ItemType Directory -Path $githubWorkflows -Force | Out-Null
    Write-Host "Created: $githubWorkflows" -ForegroundColor Cyan
}

# ----- Helper function to create a file with placeholder content -----
function Create-PlaceholderFile ($basePath, $relativePath, $content = "# placeholder") {
    $fullPath = Join-Path $basePath $relativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if (-not (Test-Path $fullPath)) {
        Set-Content -Path $fullPath -Value $content -Encoding utf8
        Write-Host "Created file: $fullPath" -ForegroundColor Yellow
    } else {
        Write-Host "File already exists: $fullPath" -ForegroundColor Gray
    }
}

# ======================
# 1. Root files (Django)
# ======================
Create-PlaceholderFile $base "Dockerfile" "# Dockerfile for Django admin`nFROM python:3.11-slim`n..."
Create-PlaceholderFile $base "manage.py" "#!/usr/bin/env python`nimport sys`nif __name__ == '__main__':`n    from django.core.management import execute_from_command_line`n    execute_from_command_line(sys.argv)"
Create-PlaceholderFile $base "requirements\base.txt" "django>=4.2`ndjangorestframework>=3.14`npsycopg2-binary>=2.9`ncelery>=5.3`nredis>=5.0"
Create-PlaceholderFile $base "requirements\dev.txt" "-r base.txt`npytest>=7.0`nmypy>=1.0`nflake8"
Create-PlaceholderFile $base "requirements\prod.txt" "-r base.txt`ngunicorn>=20.0"

# ======================
# 2. Config files
# ======================
Create-PlaceholderFile $base "config\__init__.py"
Create-PlaceholderFile $base "config\settings\base.py" "# Django settings base"
Create-PlaceholderFile $base "config\settings\dev.py" "from .base import *`nDEBUG = True"
Create-PlaceholderFile $base "config\settings\prod.py" "from .base import *`nDEBUG = False"
Create-PlaceholderFile $base "config\urls.py" "from django.contrib import admin`nfrom django.urls import path, include`n`nurlpatterns = [`n    path('admin/', admin.site.urls),`n]"
Create-PlaceholderFile $base "config\celery.py" "import os`nfrom celery import Celery`nos.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.dev')`napp = Celery('mambonami')`napp.config_from_object('django.conf:settings', namespace='CELERY')`napp.autodiscover_tasks()"
Create-PlaceholderFile $base "config\asgi.py" "import os`nfrom django.core.asgi import get_asgi_application`nos.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.dev')`napplication = get_asgi_application()"
Create-PlaceholderFile $base "config\wsgi.py" "import os`nfrom django.core.wsgi import get_wsgi_application`nos.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.dev')`napplication = get_wsgi_application()"

# ======================
# 3. Core utilities (extended)
# ======================
$coreFiles = @(
    "__init__.py",
    "utils.py",
    "throttling.py",
    "permissions.py",
    "middleware.py",
    "exceptions.py",
    "logging.py",
    "cache.py",
    "storage.py",
    "authentication.py"
)
foreach ($file in $coreFiles) {
    Create-PlaceholderFile $base "core\$file"
}
# validators subfolder
$validators = @(
    "__init__.py",
    "phone_validator.py",
    "id_number_validator.py",
    "price_validator.py"
)
foreach ($file in $validators) {
    Create-PlaceholderFile $base "core\validators\$file"
}
# management/commands subfolder
$commands = @(
    "__init__.py",
    "seed_orders.py",
    "clear_expired_otp.py",
    "check_escrow_balance.py"
)
foreach ($file in $commands) {
    Create-PlaceholderFile $base "core\management\commands\$file"
}

# ======================
# 4. Django apps (__init__.py and base files)
# ======================
$apps = @("users", "products", "orders", "payments", "paybill", "payouts", "logistics", "disputes", "notifications", "audit", "analytics")
foreach ($app in $apps) {
    Create-PlaceholderFile $base "apps\$app\__init__.py"
    Create-PlaceholderFile $base "apps\$app\urls.py" "from django.urls import path`nurlpatterns = []"
    Create-PlaceholderFile $base "apps\$app\admin.py" "from django.contrib import admin`n# Register your models here."
    Create-PlaceholderFile $base "apps\$app\tasks.py" "from celery import shared_task"
    Create-PlaceholderFile $base "apps\$app\signals.py" "from django.db.models.signals import post_save`nfrom django.dispatch import receiver"
    Create-PlaceholderFile $base "apps\$app\permissions.py" "from rest_framework import permissions"
    # Subfolders __init__.py
    Create-PlaceholderFile $base "apps\$app\models\__init__.py"
    Create-PlaceholderFile $base "apps\$app\serializers\__init__.py"
    Create-PlaceholderFile $base "apps\$app\services\__init__.py"
    Create-PlaceholderFile $base "apps\$app\views\__init__.py"
    Create-PlaceholderFile $base "apps\$app\tests\__init__.py"
    Create-PlaceholderFile $base "apps\$app\migrations\__init__.py"
}

# ======================
# 5. Model files (specific)
# ======================
Create-PlaceholderFile $base "apps\users\models\user.py" "# Farmer, Buyer, Retailer, TransportProvider models"
Create-PlaceholderFile $base "apps\products\models\category.py" "# ProductCategory model"
Create-PlaceholderFile $base "apps\products\models\product.py" "# Product model"
Create-PlaceholderFile $base "apps\orders\models\order.py" "# Order model"
Create-PlaceholderFile $base "apps\orders\models\order_item.py" "# OrderItem model"
Create-PlaceholderFile $base "apps\payments\models\payment.py" "# Payment model"
Create-PlaceholderFile $base "apps\paybill\models\transaction.py" "# M-Pesa transaction model"
Create-PlaceholderFile $base "apps\paybill\models\mpesa_callback.py" "# MpesaCallback model for idempotency"
Create-PlaceholderFile $base "apps\payouts\models\payout.py" "# Payout model"
Create-PlaceholderFile $base "apps\logistics\models\transport_provider.py" "# TransportProvider model (was rider)"
Create-PlaceholderFile $base "apps\logistics\models\trip.py" "# Trip model"
Create-PlaceholderFile $base "apps\logistics\models\otp.py" "# OTP model for delivery"
Create-PlaceholderFile $base "apps\disputes\models\dispute.py" "# Dispute model"
Create-PlaceholderFile $base "apps\notifications\models\notification.py" "# Notification model"
Create-PlaceholderFile $base "apps\audit\models\audit_log.py" "# AuditLog model"
Create-PlaceholderFile $base "apps\analytics\models\daily_metric.py" "# DailyMetric model"

# ======================
# 6. Serializers
# ======================
Create-PlaceholderFile $base "apps\users\serializers\user_serializer.py" "# User serializers"
Create-PlaceholderFile $base "apps\products\serializers\product_serializer.py" "# Product serializers"
Create-PlaceholderFile $base "apps\orders\serializers\order_serializer.py" "# Order serializers"
Create-PlaceholderFile $base "apps\payments\serializers\payment_serializer.py" "# Payment serializers"
Create-PlaceholderFile $base "apps\paybill\serializers\callback_serializer.py" "# Callback serializer"
Create-PlaceholderFile $base "apps\payouts\serializers\payout_serializer.py" "# Payout serializer"
Create-PlaceholderFile $base "apps\logistics\serializers\logistics_serializer.py" "# Logistics serializers"
Create-PlaceholderFile $base "apps\disputes\serializers\dispute_serializer.py" "# Dispute serializers"
Create-PlaceholderFile $base "apps\notifications\serializers\notification_serializer.py" "# Notification serializers"
Create-PlaceholderFile $base "apps\audit\serializers\audit_serializer.py" "# Audit serializers"
Create-PlaceholderFile $base "apps\analytics\serializers\metric_serializer.py" "# Metric serializers"

# ======================
# 7. Services
# ======================
Create-PlaceholderFile $base "apps\users\services\user_service.py" "# User business logic"
Create-PlaceholderFile $base "apps\products\services\product_service.py" "# Product logic"
Create-PlaceholderFile $base "apps\orders\services\order_service.py" "# Order logic"
Create-PlaceholderFile $base "apps\orders\services\state_machine.py" "# Order state transitions"
Create-PlaceholderFile $base "apps\payments\services\payment_service.py" "# Payment logic"
Create-PlaceholderFile $base "apps\paybill\services\ipn_handler.py" "# M-Pesa IPN callback handler"
Create-PlaceholderFile $base "apps\paybill\services\reconciliation.py" "# Reconcile payments"
Create-PlaceholderFile $base "apps\payouts\services\b2c_client.py" "# Safaricom B2C API client"
Create-PlaceholderFile $base "apps\payouts\services\payout_service.py" "# Payout logic"
Create-PlaceholderFile $base "apps\logistics\services\matching.py" "# Provider matching + vehicle type suggestion (merged)"
Create-PlaceholderFile $base "apps\logistics\services\otp_service.py" "# OTP generation/validation"
Create-PlaceholderFile $base "apps\logistics\services\geolocation.py" "# Distance calculation"
Create-PlaceholderFile $base "apps\disputes\services\resolution.py" "# Dispute resolution logic"
Create-PlaceholderFile $base "apps\notifications\services\whatsapp.py" "# WhatsApp integration"
Create-PlaceholderFile $base "apps\notifications\services\email.py" "# Email integration"
Create-PlaceholderFile $base "apps\notifications\services\push.py" "# Push notifications (Firebase)"
Create-PlaceholderFile $base "apps\audit\services\logger.py" "# Audit log creation"
Create-PlaceholderFile $base "apps\analytics\services\aggregator.py" "# Daily metric aggregation"
Create-PlaceholderFile $base "apps\analytics\services\reports.py" "# Generate reports"

# ======================
# 8. Views (api.py)
# ======================
Create-PlaceholderFile $base "apps\users\views\api.py" "# User API views"
Create-PlaceholderFile $base "apps\products\views\api.py" "# Product API views"
Create-PlaceholderFile $base "apps\orders\views\api.py" "# Order API views"
Create-PlaceholderFile $base "apps\payments\views\api.py" "# Payment API views"
Create-PlaceholderFile $base "apps\paybill\views\api.py" "# PayBill callback view (POST /mpesa/callback)"
Create-PlaceholderFile $base "apps\payouts\views\api.py" "# Payout API views"
Create-PlaceholderFile $base "apps\logistics\views\api.py" "# Transport API views"
Create-PlaceholderFile $base "apps\disputes\views\api.py" "# Dispute API views"
Create-PlaceholderFile $base "apps\notifications\views\api.py" "# Notification API views"
Create-PlaceholderFile $base "apps\audit\views\api.py" "# Audit log API views"
Create-PlaceholderFile $base "apps\analytics\views\api.py" "# Analytics API views"

# ======================
# 9. Tests (simple placeholder per app, plus specific ones)
# ======================
foreach ($app in $apps) {
    Create-PlaceholderFile $base "apps\$app\tests\test_models.py" "from django.test import TestCase`n# Add model tests"
}
# Additional specific test files
Create-PlaceholderFile $base "apps\orders\tests\test_order_flow.py" "# Order flow tests"
Create-PlaceholderFile $base "apps\paybill\tests\test_ipn.py" "# IPN callback tests"
Create-PlaceholderFile $base "apps\payouts\tests\test_b2c.py" "# B2C payout tests"
Create-PlaceholderFile $base "apps\logistics\tests\test_matching.py" "# Provider matching tests"
Create-PlaceholderFile $base "apps\disputes\tests\test_disputes.py" "# Dispute resolution tests"
Create-PlaceholderFile $base "apps\notifications\tests\test_notifications.py" "# Notification tests"
Create-PlaceholderFile $base "apps\audit\tests\test_audit.py" "# Audit log tests"
Create-PlaceholderFile $base "apps\analytics\tests\test_analytics.py" "# Analytics tests"

# ======================
# 10. FastAPI app (full files)
# ======================
Create-PlaceholderFile $fastapiBase "Dockerfile" "FROM python:3.11-slim`nWORKDIR /app`nCOPY requirements.txt .`nRUN pip install --no-cache-dir -r requirements.txt`nCOPY . .`nCMD [\"uvicorn\", \"main:app\", \"--host\", \"0.0.0.0\", \"--port\", \"8000\"]"
Create-PlaceholderFile $fastapiBase "requirements.txt" "fastapi>=0.100.0`nuvicorn>=0.23.0`nprometheus-client>=0.17.0"
Create-PlaceholderFile $fastapiBase "main.py" "from fastapi import FastAPI`nfrom api.v1.endpoints import health, metrics`n`napp = FastAPI(title='MAMBONAMI API Gateway')`n`napp.include_router(health.router, tags=['health'])`napp.include_router(metrics.router, tags=['metrics'])`n`n@app.get('/')`ndef root():`n    return {'message': 'MAMBONAMI API Gateway'}"
# endpoints
Create-PlaceholderFile $fastapiBase "api\__init__.py"
Create-PlaceholderFile $fastapiBase "api\v1\__init__.py"
Create-PlaceholderFile $fastapiBase "api\v1\endpoints\__init__.py"
Create-PlaceholderFile $fastapiBase "api\v1\endpoints\health.py" "from fastapi import APIRouter`n`nrouter = APIRouter()@router.get('/health')`ndef health_check():`n    return {'status': 'ok'}"
Create-PlaceholderFile $fastapiBase "api\v1\endpoints\metrics.py" "from fastapi import APIRouter`nfrom prometheus_client import generate_latest, CONTENT_TYPE_LATEST`nfrom fastapi.responses import Response`n`nrouter = APIRouter()@router.get('/metrics')`ndef metrics():`n    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)"
# core
Create-PlaceholderFile $fastapiBase "core\__init__.py"
Create-PlaceholderFile $fastapiBase "core\config.py" "class Settings:`n    ..."
Create-PlaceholderFile $fastapiBase "core\security.py" "# Auth dependencies (JWT, API keys)"
Create-PlaceholderFile $fastapiBase "core\dependencies.py" "from fastapi import Depends, HTTPException, status`n# Shared dependencies like get_db, get_current_user"
Create-PlaceholderFile $fastapiBase "core\logging.py" "import logging`nlogging.basicConfig(level=logging.INFO)`nlogger = logging.getLogger('mambonami')"
# other FastAPI folders
Create-PlaceholderFile $fastapiBase "models\__init__.py"
Create-PlaceholderFile $fastapiBase "schemas\__init__.py"
Create-PlaceholderFile $fastapiBase "services\__init__.py"

# ======================
# 11. GitHub workflows
# ======================
Create-PlaceholderFile $githubBase "workflows\django_ci.yml" @"
name: Django CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    - name: Install dependencies
      run: |
        cd backend/django_admin
        pip install -r requirements/dev.txt
    - name: Run tests
      run: |
        cd backend/django_admin
        python manage.py test
"@
Create-PlaceholderFile $githubBase "workflows\deploy.yml" @"
name: Deploy to Production
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy via SSH
      run: echo "Add your deployment script here"
"@

# ======================
# 12. Static placeholder
# ======================
Create-PlaceholderFile $base "static\.gitkeep" "# Keep static folder"

Write-Host "`n✅ Complete backend structure created under $base and $fastapiBase" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Magenta
Write-Host "1. cd backend/django_admin" -ForegroundColor Yellow
Write-Host "2. pip install -r requirements/dev.txt" -ForegroundColor Yellow
Write-Host "3. python manage.py migrate" -ForegroundColor Yellow
Write-Host "4. Start coding the 'paybill' app first (IPN handler + idempotency)" -ForegroundColor Cyan