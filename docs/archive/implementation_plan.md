# MAMBONAMI – Implementation Plan v1.0

## 1. Overview

MAMBONAMI is a three‑sided marketplace (Farmers → Buyers → Transport Providers) with escrow payments via M‑Pesa PayBill and B2C payouts. This document defines the technical implementation roadmap, architecture decisions, and development standards.

---

## 2. Technology Stack

| Layer | Technology |
|-------|------------|
| Backend (business logic) | Django 4.2 + Django REST Framework |
| API Gateway | FastAPI (lightweight routing, health checks, metrics) |
| Database | PostgreSQL 15 |
| Task Queue | Celery 5.3 + Redis |
| Payment Integration | Safaricom M‑Pesa PayBill (collections) + B2C API |
| Caching | Redis |
| File Storage | Django storage backend (local for dev, S3 for production) |
| Frontend (Admin/Retailer) | React + TypeScript + Tailwind |
| Mobile (Buyer/Farmer/Provider) | Flutter |
| Reverse Proxy | Nginx |
| Containerisation | Docker + Docker Compose |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus + Grafana (via FastAPI `/metrics`) |

---

## 3. Repository Structure

The repository follows a **monorepo** pattern:
mambonami/
├── backend/
│ ├── requirements/ # base.txt, dev.txt, prod.txt
│ ├── django_admin/ # Django project
│ │ ├── core/ # shared utilities (no models)
│ │ ├── apps/ # all Django apps
│ │ ├── config/ # settings, URLs, Celery
│ │ └── manage.py
│ └── fastapi_app/ # API gateway (health, metrics, proxy)
├── shared/ # code shared between Django & FastAPI
│ ├── db_models/ # base model classes (Abstract models)
│ │ ├── base.py # BaseModel with id + uuid
│ │ └── mixins.py # TimestampMixin, SoftDeleteMixin
│ └── enums.py # shared enums (OrderStatus, VehicleType)
├── mobile/ # Flutter app
├── web/ # React dashboard
├── docker-compose.yml
├── Makefile
└── docs/ # all documentation

---

## 4. Key Technical Decisions

### 4.1 Primary Keys: AutoField `id` + Public `uuid`

- **Internal**: `id` – integer auto‑increment, used for foreign keys, PayBill account numbers (`ORD-{id}`), and internal queries.
- **Public**: `uuid` – exposed in URLs and API responses to prevent ID enumeration.
- **Implementation**: Abstract `BaseModel` in `shared/db_models/base.py`.

```python
# shared/db_models/base.py
import uuid
from django.db import models

class BaseModel(models.Model):
    id = models.AutoField(primary_key=True)
    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
```

### 4.2 Django Apps (11 total)
App	Responsibility
users	Farmer, Buyer, Retailer, TransportProvider models; registration, JWT auth
products	Product categories, listings, harvest dates
orders	Cart, order splitting, state machine
payments	Abstract payment records (may merge into paybill later)
paybill	M‑Pesa PayBill IPN handler, idempotency, transaction logs
payouts	B2C payouts to farmers & transport providers
logistics	Transport provider matching, trip tracking, OTP delivery
disputes	Dispute creation, resolution, partial refunds
notifications	WhatsApp, email, push (Firebase)
audit	Admin action logging (immutable)
analytics	Daily metrics aggregation, reports
### 4.3 Shared Utilities (django_admin/core/)
This folder is not a Django app – it contains cross‑cutting concerns:

authentication.py – custom JWT handling, role‑based permissions

cache.py – Redis helpers (e.g., cache OTPs, order details)

storage.py – S3 file storage backend

logging.py – structured logging for Celery and requests

middleware.py – request ID, exception handling

throttling.py – rate limits per user role

validators/ – phone, ID number, price, GPS coordinates

management/commands/ – custom CLI tools

### 4.4 Shared Enums (shared/enums.py)
Centralise all enums (e.g., OrderStatus, VehicleType, DisputeStatus) to be imported by both Django and FastAPI.

## 5. Development Phases (Sprints)
Sprint 1: Foundation & PayBill (Week 1‑2)
Goal: Escrow payment working end‑to‑end.

Set up Django project, PostgreSQL, Redis, Celery.

Implement shared/db_models/base.py.

Create paybill app:

Model MpesaCallback for idempotency.

IPN endpoint (/mpesa/callback/) with idempotency check.

Transaction model to store all PayBill collections.

Create orders app minimal:

Order model with status Placed → Paid (Escrow).

Ability to generate unique Account Number ORD-{id}.

Write tests for IPN handling (duplicate callbacks, invalid Account Number).

Deliverable: Admin can see incoming payments and orders changed to Paid (Escrow).

Sprint 2: Users & Products (Week 3‑4)
users app:

Custom User model with roles (Farmer, Buyer, Retailer, TransportProvider).

Registration with OTP verification (phone).

JWT authentication (simpleJWT) – integrate with core/authentication.py.

Admin approval workflow for farmers (cooperative endorsement) and transport providers (background check).

products app:

Category and Product models.

Farmers can list products with harvest date, price, quantity.

Deliverable: Users can register, log in, and farmers can publish products.

Sprint 3: Order Flow & Logistics (Week 5‑6)
Complete orders app:

Cart (multi‑farmer), split into sub‑orders.

State machine (Order → Paid → FarmerConfirmed → FarmerReady → TransportAssigned → PickedUp → Delivered).

Farmer confirmation timeouts (30 min → auto‑cancel).

logistics app:

TransportProvider model (vehicle type, capacity, deposit status).

Matching algorithm (find_nearest_providers + suggest_vehicle_type).

OTP generation/validation (4 digits, 5 min expiry).

Trip model (tracks provider, pickup/delivery photos, GPS trails).

Deliverable: Full order lifecycle from buyer payment to transport provider delivery, including OTP confirmation.

Sprint 4: Payments & Payouts (Week 7‑8)
payouts app:

B2C client (Safaricom API wrapper).

Payout model and service to trigger B2C after delivery confirmation.

Handle float management: check balance, queue if insufficient, retry.

disputes app:

Dispute creation (buyer, farmer, provider).

Admin resolution panel (partial refund via B2C, penalty deduction).

Deliverable: Farmers and transport providers receive real M‑Pesa payments after successful delivery; disputes can be resolved.

Sprint 5: Notifications & Admin Dashboard (Week 9‑10)
notifications app:

WhatsApp (Twilio API), email (SendGrid), push (Firebase Cloud Messaging).

Template system for order updates, OTPs, dispute alerts.

Web dashboard (React):

Admin: farmer/provider approval, dispute resolution, audit log viewer, reports.

Retailer: bulk ordering (future – Phase 2).

Deliverable: All stakeholders receive real‑time notifications; admin can manage platform.

Sprint 6: Testing, CI/CD, Deployment (Week 11‑12)
Testing: Unit tests (>=80% coverage) for all apps, integration tests (end‑to‑end order flow with mock M‑Pesa).

CI/CD: GitHub Actions (run tests on push, deploy to staging on merge to main).

Deployment: Docker Compose for staging; production on a VPS (e.g., DigitalOcean) with Nginx, PostgreSQL, Redis.

Monitoring: FastAPI /health and /metrics endpoints; Prometheus + Grafana.

Go‑Live Checklist: Confirm PayBill reserve floor with Safaricom, test B2C payouts in sandbox, verify idempotency, train support team.

- **Critical gaps checklist** – verify all items from Section 17 of `business_logic.md` (float reserve, idempotency, OTP flow, cooperative verification, real deposit).

6. Database Schema Highlights
Model	Key Fields	Relationships
User (abstract)	phone, role, is_active	–
Farmer	coop_verified, bank_mpesa, farm_gps	OneToOne to User
TransportProvider	vehicle_type, capacity_kg, deposit_paid	OneToOne to User
Product	farmer, category, price, harvest_date	ForeignKey to Farmer
Order	buyer, status, total_amount, account_number	ForeignKey to Buyer
OrderItem	order, product, quantity, unit_price	ForeignKey to Order, Product
Transaction (paybill)	transaction_code, amount, account_number	–
MpesaCallback	transaction_code (PK), order_id, processed_at	–
Payout	order, recipient_type, amount, b2c_status	ForeignKey to Order
Trip	order, provider, otp_code, pickup_photo, delivery_photo	ForeignKey to Order, TransportProvider
Dispute	order, raised_by, reason, status, resolution	ForeignKey to Order
AuditLog	admin_user, action, model_name, object_id, timestamp	–
All business models inherit from BaseModel (id, uuid, created_at, updated_at).

7. API Design (Django REST Framework)
All endpoints return JSON. Public endpoints use uuid in URLs; internal calls may use id.

Endpoint	Method	Description
/api/v1/auth/register/	POST	Register user (role in payload)
/api/v1/auth/login/	POST	Returns JWT
/api/v1/products/	GET	List products (filter by category, farmer)
/api/v1/products/	POST	Farmer creates product
/api/v1/cart/	POST	Add items, returns split orders
/api/v1/orders/	POST	Create order, returns PayBill details
/api/v1/orders/{uuid}/	GET	Order details
/api/v1/orders/{uuid}/confirm/	POST	Farmer confirms order
/api/v1/orders/{uuid}/ready/	POST	Farmer marks ready
/api/v1/orders/{uuid}/deliver/	POST	Transport provider: generate OTP
/api/v1/orders/{uuid}/verify-otp/	POST	Buyer enters OTP + photo upload
/mpesa/callback/	POST	Safaricom IPN (no auth)
/api/v1/admin/...	–	All admin endpoints (role required)
FastAPI gateway routes requests to Django (except /health, /metrics which it serves directly).

8. Critical Implementation Checklist (from Section 17 of Business Logic)
PayBill float reserve – confirm with Safaricom that manual settlement or reserve floor (KES 200,000) is possible.

Idempotency table – mpesa_callbacks with unique transaction_code, check before processing IPN.

OTP delivery flow – 4‑digit OTP, 5 min expiry, max 3 attempts, mandatory geo‑tagged photo.

Cooperative verification – admin workflow to mark coop_verified = true after calling cooperative.

Transport provider deposit – real KES 500 payment via PayBill with DEP-TRANSPORT-{id} before activation.

9. Testing Strategy
Level	Tools	Focus
Unit	pytest, pytest-django	Models, serializers, services (matching, payout logic)
Integration	pytest, factory_boy	API endpoints, Celery tasks, IPN handling
End‑to‑End	Playwright (web) + Flutter driver	Full order flow (sandbox M‑Pesa)
Load	Locust	Simulate 100 concurrent orders, monitor Celery queue
Required coverage: ≥80% for all apps except audit and analytics (≥60% initial).

10. Deployment (Production)
Environment variables (.env):

env
DJANGO_SECRET_KEY=...
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
MPESA_PAYBILL_NUMBER=123456
MPESA_CONSUMER_KEY=...
MPESA_CONSUMER_SECRET=...
MPESA_B2C_INITIATOR_NAME=...
MPESA_B2C_SECURITY_CREDENTIAL=...
AWS_ACCESS_KEY_ID=...   # for S3
AWS_SECRET_ACCESS_KEY=...
Docker Compose (simplified):

yaml
services:
  postgres:
    image: postgres:15
  redis:
    image: redis:7
  django:
    build: ./backend/django_admin
    environment: ...
    depends_on: [postgres, redis]
  fastapi:
    build: ./backend/fastapi_app
  nginx:
    image: nginx:alpine
    ports: ["80:80", "443:443"]
Deployment steps:

Push to main branch → GitHub Actions runs tests.

If tests pass, build Docker images and push to registry (e.g., GHCR).

SSH into production server, pull images, run docker-compose up -d.

Run migrations (docker exec django python manage.py migrate).

Verify /health endpoint returns 200.

11. Monitoring & Alerts
Health checks: FastAPI /health (200 if DB and Redis reachable).

Metrics: /metrics endpoint exposed for Prometheus (request count, latency, error rate, PayBill float balance).

Alerts (via Grafana):

Float balance < KES 100,000 (critical – unable to pay B2C).

IPN failures > 5 per minute.

Delayed Celery tasks (> 5 minutes).

12. Risk Mitigation
Risk	Mitigation
Safaricom IPN downtime	Queue IPN payloads in Redis, process when endpoint is back; manual reconciliation script.
B2C payout fails	Retry with exponential backoff; fallback to manual payout report for support team.
Transport provider fraud	Real deposit (KES 500); OTP + photo proof; rating system.
Farmer cancels after pickup	Penalty: farmer forfeits delivery fee (deducted from future payouts).
Escrow float insufficiency	Reserve floor + manual settlement threshold; queue B2C payouts; notify admin.
13. Next Steps (Immediate Actions)
Update backend_structure.ps1 to complete the full folder layout.

Implement shared/db_models/base.py and shared/enums.py.

Start Sprint 1: build paybill app with idempotency and IPN handler.

Use the sandbox M‑Pesa API to test callbacks.

After Sprint 1, unblock orders and proceed to users & products.

Document version: 1.0
Last updated: May 2025
Owner: Development Team