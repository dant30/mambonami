# MAMBONAMI – Master Specification

## 1. Overview ✅✅

MAMBONAMI is a three-sided marketplace (Farmers → Buyers → Transport Providers) with escrow payments via M-Pesa PayBill and B2C payouts. The platform connects fresh produce suppliers directly to buyers, coordinates independent transport providers, and uses PayBill-based escrow to protect payments until delivery confirmation.

## 2. Technology Stack ✅✅

| Layer | Technology |
|-------|------------|
| Backend (business logic) | Django 4.2 + Django REST Framework |
| API Gateway | FastAPI (lightweight routing, health checks, metrics) |
| Database | PostgreSQL 15 |
| Task Queue | Celery 5.3 + Redis |
| Payment Integration | Safaricom M-Pesa PayBill (collections) + B2C API |
| Caching | Redis |
| File Storage | Django storage backend (local for dev, S3 for production) |
| Frontend (Admin/Retailer) | React + TypeScript + Tailwind |
| Mobile (Buyer/Farmer/Provider) | Flutter |
| Reverse Proxy | Nginx |
| Containerisation | Docker + Docker Compose |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus + Grafana (via FastAPI `/metrics`) |

## 3. Repository Structure ✅✅

The repository follows a monorepo pattern:

```
mambonami/
├── backend/
│   ├── requirements/ # base.txt, dev.txt, prod.txt
│   ├── django_admin/ # Django project
│   │   ├── core/ # shared utilities (no models)
│   │   ├── apps/ # all Django apps
│   │   ├── config/ # settings, URLs, Celery
│   │   └── manage.py
│   └── fastapi_app/ # API gateway (health, metrics, proxy)
├── shared/ # code shared between Django & FastAPI
│   ├── db_models/ # base model classes (Abstract models)
│   │   ├── base.py # BaseModel with id + uuid
│   │   └── mixins.py # TimestampMixin, SoftDeleteMixin
│   └── enums.py # shared enums (OrderStatus, VehicleType)
├── mobile/ # Flutter app
├── web/ # React dashboard
├── docker-compose.yml
├── Makefile
└── docs/ # all documentation
```

## 4. Core Principles ✅✅

- No owned fleet – Delivery is performed by independent, registered transport providers (motorbikes, pickups, lorries, vans, etc.).
- Three-sided marketplace – Farmers | Buyers (retailers + consumers) | Transport providers.
- Traceability – Every product batch is linked to a specific farmer and harvest date.
- Fair pricing – Farmers see suggested market prices; buyers see transparent markups.
- Escrow-based payments – Buyer funds are held securely by the platform (via M-Pesa PayBill collection account) until delivery is confirmed, then released to farmer and transport provider via M-Pesa B2C.

## 5. The Problem We Solve ✅✅

| Stakeholder | Problem |
|-------------|---------|
| Farmers | Rely on brokers → low profits |
| Retailers | Inconsistent supply |
| Consumers | High prices, low freshness |
| Entire chain | Fragmented, no transparency in pricing or sourcing |

## 6. Our Solution ✅✅

MAMBONAMI provides:
- Direct farmer access to markets
- Real-time ordering system
- Integrated logistics (pickup + delivery)
- Transparent pricing & product traceability

## 7. User Roles & Registration Data ⚠️⚠️

| Role | Required Info | Verification |
|------|---------------|--------------|
| Farmer | Full name, ID number, farm location (GPS), product categories, bank/M-Pesa number | Phone OTP + **cooperative endorsement (required, with waiver for unaffiliated farmers)** |
| Retailer | Business name, physical shop address, PIN (if registered) | Business permit upload (future) |
| Consumer | Name, delivery address(es), phone number | Phone OTP |
| **Transport Provider** | Full name, ID, **vehicle type** (motorbike/pickup/lorry/van), **vehicle registration**, **driver’s license**, photo | Background check (manual first), liability waiver, **real deposit of KES 500 via M-Pesa PayBill** |

### 7.1 Cooperative Endorsement ⚠️⚠️

- Cooperative endorsement is **required** for farmers, but unaffiliated farmers may use a waiver.
- For endorsed farmers, the platform verifies by calling the cooperative or receiving a digital letter.
- Store `coop_verified = true/false`.
- Verified farmers receive higher trust and priority listings.

### 7.2 Transport Provider Deposit ⚠️⚠️

- Providers must **actually pay KES 500 via M-Pesa PayBill** to account number `DEP-TRANSPORT-{provider_id}`.
- The deposit is held in the PayBill float and refunded via B2C if the provider leaves in good standing.
- This discourages fraud and ensures financial accountability.

## 8. Product Categories & Units ⚠️⚠️

| Code | Category | Examples | Base Unit |
|------|----------|----------|------------|
| MA | Matunda (fruits) | mango, banana, orange, avocado | kg / piece |
| MBO | Mboga (vegetables) | sukuma wiki, spinach, cabbage, tomato | kg / bunch |
| NA | Nafaka (grains) | maize, beans, rice, lentils | kg |
| MI | Mizizi (roots) | potato, cassava | kg |
| MI | Miche (seedlings) | tree seedlings, vegetable seedlings | piece |
| MI | Mifugo (livestock products) | eggs (tray), milk (litre), chicken (whole), goat | litre / tray / piece |

Farmers must list one category, unit, price per unit, available quantity, and harvest/pack date.

## 9. Order & Delivery Logic ⚠️⚠️

### 9.1 Order Placement ⚠️⚠️

- Buyers add items from one or more farmers to a cart.
- The platform splits the cart into farmer-specific sub-orders.
- Buyer selects delivery date/time window and pays via M-Pesa PayBill.
- Platform calculates:
  - Subtotal (farmer price × quantity)
  - Service fee (commission)
  - Delivery fee
- Payment instructions show: Pay KES XXXX to PayBill `123456`, Account Number `ORD-12345`.

### 9.2 What Happens After Buyer Pays ⚠️⚠️

**Step A – Safaricom processes the payment:**
- Buyer pays PayBill `123456` with the generated account number.
- Safaricom debits the buyer and holds funds in the merchant ledger.

**Step B – Instant callback (IPN) to MAMBONAMI:**
- Endpoint: `POST https://api.mambonami.com/mpesa/callback`
- Payload includes `TransactionCode`, `Amount`, `AccountNumber`, `PhoneNumber`, `Time`.
- Idempotency check is mandatory:
  - If `TransactionCode` already exists, return `200 OK` and do nothing.
  - If new, mark the order as PAID.

**Step C – Platform records escrow:**
- The money is logically held by MAMBONAMI in the PayBill ledger.
- It is not available in the bank account until Safaricom settlement.

### 9.3 Farmer Order Fulfillment ⚠️⚠️

Once payment callback is received and order is marked Paid:
1. Farmer receives notifications (in-app + WhatsApp).
2. Farmer must confirm or reject within 30 minutes.
   - If cancelled, the system triggers a refund via B2C.
3. If accepted, farmer marks the order ready for pickup.
4. Transport providers are notified only after the order is ready.

### 9.4 Transport Matching & Delivery Fees ⚠️⚠️

- Delivery fees are dynamic:
  - Base fee per km
  - Waiting time surcharge after 15 minutes
  - Bulky item surcharge for heavy orders
- Transport providers receive 80% of the delivery fee.
- Providers may accept or decline offers.
- If no provider accepts within 10 minutes:
  1. Re-offer with +10% fee
  2. Escalate to admin after a second failure
- Providers are matched by vehicle type and capacity.

### 9.5 Delivery State Machine ⚠️⚠️

```
Order Placed → Paid (Escrow) → Farmer Confirmed → Farmer Ready → Transport Assigned → Transport Picked Up → Delivered
    ↓ (reject/timeout)         ↓ (farmer no-response)    ↓ (decline)           ↓ (issue)
  Cancelled                 Cancelled                    Re-offer           Escalate to support
```

### 9.6 Proof of Delivery & Escrow Release ⚠️⚠️

- Transport provider clicks **Deliver** at the buyer location.
- App generates a random 4-digit OTP valid for 5 minutes.
- Buyer enters the OTP and the provider captures a geo-tagged photo.
- If OTP expires, provider requests a new code (max 3 attempts).
- On confirmation, platform triggers B2C payouts to farmer and provider.
- If buyer disputes, funds remain in escrow until resolution.

## 10. M-Pesa PayBill Integration ⚠️⚠️

### 10.1 PayBill Setup ⚠️⚠️

- Apply for a Safaricom PayBill number.
- Required business registration, KYC, and tax compliance.
- The PayBill ledger is the platform’s holding account.
- Payouts are made from the PayBill float, not the bank settlement account.

### 10.2 Collection Flow ⚠️⚠️

| Step | Description |
|------|-------------|
| 1 | Buyer pays PayBill with `ORD-{order_id}` |
| 2 | Safaricom debits buyer and holds funds |
| 3 | Safaricom sends IPN callback to our server |
| 4 | System verifies order and idempotency |
| 5 | Order status becomes Paid (Escrow) |

### 10.3 Reconciliation ⚠️⚠️

- Each order uses a unique account number like `ORD-{order_id}`.
- IPN callbacks map directly to pending orders.

### 10.4 B2C Payout Flow ❌❌

- After delivery confirmation, the platform calls the Safaricom B2C API.
- Farmer receives product payout; transport provider receives delivery fee share.
- Payouts draw from the PayBill float.

### 10.5 Refunds ⚠️⚠️

- PayBill transactions cannot be reversed.
- Refunds are issued via B2C payments.
- Cancellation rules:
  - Free within 5 minutes.
  - 10% fee after 5 minutes before farmer confirmation.
  - Larger penalty once farmer confirms.

### 10.6 Bank Settlement ⚠️⚠️

- Safaricom settles PayBill balances to the bank daily/weekly.
- Settlement funds are for operations, not immediate payouts.

### 10.7 Fees ⚠️⚠️

- Safaricom charges PayBill and B2C fees.
- Platform charges a commission on product sales and delivery fees.

## 12. Shared Models & Platform Primitives ✅

This platform includes shared Python primitives to keep backend model logic consistent across Django and FastAPI components.

- `shared/enums.py`
  - `OrderStatus` defines order lifecycle states: `cart`, `placed`, `paid_escrow`, `transport_assigned`, `picked_up`, `delivered`, `cancelled`, `disputed`.
  - `VehicleType` captures transport provider vehicle categories: `motorcycle`, `pickup`, `van`, `lorry`.
  - `NotificationChannel` standardizes delivery channels: `in_app`, `sms`, `email`.

- `shared/db_models/mixins.py`
  - `TimestampMixin` provides `created_at` and `updated_at` fields for auditability.
  - `SoftDeleteMixin` provides `is_deleted`, `deleted_at`, `delete()`, and `restore()` for logical deletion workflows.

## 13. Mobile Navigation & Deep-Linking Priority ✅

Mobile app behavior must support direct entry points and fallback navigation when users arrive from external links or notifications.

- Deep links should resolve to productive buyer and farmer experiences even if the app starts from the login screen.
- Buyer cart deep links (`/cart`) are supported and preserve user flow by redirecting unauthenticated users to login and then to cart.
- Screens opened directly through deep links should show a fallback back action when there is no existing navigator history.
- Notification payloads may include `deepLink` metadata that maps onto existing app routes.

## 14. Feature Priorities ⚠️

- Buyer cart & checkout flow, including deep linking from notifications and web links.
- Order tracking and notification delivery acknowledgements.
- Transport provider matching by vehicle type and delivery capacity.
- Soft delete support for entities that should be hidden rather than permanently removed.
- Universal shared backend enums and model mixins to prevent divergence across services.

## 15. Pre-Deployment Validation ✅

- Verify deep-link routing for buyer cart, product detail, order tracking, and farmer order detail.
- Confirm notification deep link metadata flows to the correct in-app screens.
- Validate that soft-deleted records are excluded from active queries but recoverable when required.

### 11.1 PayBill Float Funding Risk ⚠️⚠️

- The PayBill float may be settled to the bank overnight.
- Mandatory: Maintain a reserve floor of KES 200,000 in the PayBill float.
- Work with Safaricom to set a manual settlement threshold that never drains the float below this amount.
- Consider a Safaricom Merchant Overdraft for temporary gaps.

### 11.2 IPN Idempotency ✅✅

- Store each `TransactionCode` in an `mpesa_callbacks` table.
- Pseudocode:

```sql
CREATE TABLE mpesa_callbacks (
    transaction_code VARCHAR(50) PRIMARY KEY,
    order_id INT,
    processed_at TIMESTAMP,
    UNIQUE KEY (transaction_code)
);
```

```pseudo
IF transaction_code already exists:
    RETURN 200 OK (do nothing)
ELSE:
    Process payment, mark order PAID
```

### 11.3 OTP Delivery Confirmation ⚠️⚠️

- Use a concrete OTP flow rather than vague confirmation.
- 4-digit OTP, 5-minute expiry, photo capture required.
- This prevents fake deliveries.

### 11.4 Cooperative Verification ⚠️⚠️

- Make cooperative endorsement required for farmers.
- Allow waivers only for unaffiliated farmers.
- Verify cooperatives by phone or digital letter.
- Store `coop_verified` status.

### 11.5 Real Transport Provider Deposit ⚠️⚠️

- Collect KES 500 via PayBill with `DEP-TRANSPORT-{provider_id}`.
- Track the deposit in the PayBill float.
- Refund via B2C when the provider exits in good standing.

## 12. System Components ✅✅

### 12.1 Django Apps ⚠️⚠️

- `users`
- `products`
- `orders`
- `payments`
- `paybill`
- `payouts`
- `logistics`
- `disputes`
- `notifications`
- `audit`
- `analytics`

### 12.2 Shared Utilities (`django_admin/core/`) ⚠️⚠️

- `authentication.py` – custom JWT handling, role-based permissions
- `cache.py` – Redis helpers
- `storage.py` – S3/file storage backend
- `logging.py` – structured logging
- `middleware.py` – request ID, exceptions
- `throttling.py` – rate limits
- `validators/` – phone, ID number, price, GPS coordinates
- `management/commands/` – custom CLI tools

### 12.3 Shared Enums ⚠️⚠️

- `shared/enums.py` for shared domain values such as `OrderStatus`, `VehicleType`, `DisputeStatus`.

### 12.4 FastAPI Gateway ✅✅

- `backend/fastapi_app/main.py`
- `/health` and `/metrics` endpoints
- `core/dependencies.py`, `core/logging.py`, `core/security.py`
- Lightweight proxy to Django backend

## 13. API Design ⚠️⚠️

All endpoints return JSON. Public API endpoints use UUIDs for external references.

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/auth/register/` | POST | Register user |
| `/api/v1/auth/login/` | POST | Returns JWT |
| `/api/v1/products/` | GET | List products |
| `/api/v1/products/` | POST | Farmer creates product |
| `/api/v1/cart/` | POST | Add items, return split orders |
| `/api/v1/orders/` | POST | Create order, return PayBill details |
| `/api/v1/orders/{uuid}/` | GET | Order details |
| `/api/v1/orders/{uuid}/confirm/` | POST | Farmer confirms order |
| `/api/v1/orders/{uuid}/ready/` | POST | Farmer marks ready |
| `/api/v1/orders/{uuid}/deliver/` | POST | Generate OTP |
| `/api/v1/orders/{uuid}/verify-otp/` | POST | Buyer enters OTP + photo upload |
| `/mpesa/callback/` | POST | Safaricom IPN |
| `/api/v1/admin/...` | – | Admin endpoints |

## 14. Development Plan ⚠️⚠️

### 14.1 Sprint 1: Foundation & PayBill (Week 1-2)

- Set up Django, PostgreSQL, Redis, Celery.
- Implement `shared/db_models/base.py`.
- Create `paybill` app and IPN endpoint.
- Add idempotency and transaction logging.
- Create minimal `orders` app and unique account number generation.
- Write tests for duplicate callbacks and invalid account numbers.

### 14.2 Sprint 2: Users & Products (Week 3-4)

- Custom User model with roles.
- OTP registration and JWT auth.
- Admin approval workflow.
- Product categories and farmer listings.

### 14.3 Sprint 3: Order Flow & Logistics (Week 5-6)

- Complete orders app with cart splitting and state machine.
- Build transport provider matching, OTP flow, and trip tracking.

### 14.4 Sprint 4: Payments & Payouts (Week 7-8)

- Implement B2C payout service.
- Add payout queueing and retries.
- Build disputes workflow and partial refunds.

### 14.5 Sprint 5: Notifications & Admin Dashboard (Week 9-10)

- Add WhatsApp, email, and push notifications.
- Build admin dashboard for approvals, disputes, and reports.

### 14.6 Sprint 6: Testing, CI/CD, Deployment (Week 11-12)

- Achieve >=80% coverage for major apps.
- Set up GitHub Actions for tests and linting.
- Deploy staging with Docker Compose.
- Expose FastAPI `/health` and `/metrics`.
- Add a go-live checklist.

- **Critical gaps checklist** – verify all items from Section 17 of `business_logic.md` (float reserve, idempotency, OTP flow, cooperative verification, real deposit).

## 15. Testing Strategy ⚠️⚠️

| Level | Tools | Focus |
|-------|-------|-------|
| Unit | pytest, pytest-django | Models, serializers, services |
| Integration | pytest, factory_boy | API endpoints, Celery tasks, IPN handling |
| End-to-End | Playwright, Flutter driver | Full order flow |
| Load | Locust | Concurrent order simulation |

## 16. Deployment ⚠️⚠️

### 16.1 Environment Variables

- `DJANGO_SECRET_KEY`
- `DATABASE_URL`
- `REDIS_URL`
- `MPESA_PAYBILL_NUMBER`
- `MPESA_CONSUMER_KEY`
- `MPESA_CONSUMER_SECRET`
- `MPESA_B2C_INITIATOR_NAME`
- `MPESA_B2C_SECURITY_CREDENTIAL`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 16.2 Docker Compose

Services include PostgreSQL, Redis, Django, FastAPI, and Nginx.

### 16.3 Deployment Steps

- Merge to main and run GitHub Actions.
- Build Docker images.
- Deploy to staging or production server.
- Run migrations and verify `/health`.

## 17. Monitoring & Alerts ⚠️⚠️

- `/health` endpoint for liveness.
- `/metrics` endpoint for Prometheus.
- Alerts for low float, IPN failures, and delayed tasks.

## 18. Risk Mitigation ⚠️⚠️

| Risk | Mitigation |
|------|------------|
| IPN downtime | Queue callbacks and reconcile later |
| B2C payout failure | Retry and manual payout report |
| Transport fraud | Real deposit, OTP, photo proof |
| Late cancellation | Penalty and refund rules |
| Float insufficiency | Reserve floor, settlement threshold |

## 19. Next Steps ⚠️⚠️

- Finalise `backend_structure.ps1`.
- Implement shared database models and enums.
- Start Sprint 1 with PayBill and IPN.
- Validate the flow against Safaricom sandbox.
- Use `MASTER_SPEC.md` as the single source of truth.

---

Document version: 1.0
Last updated: May 2026
Owner:Mambonami Development Team
