# MAMBONAMI – Business Logic Document (v1.3 – PayBill-Ready + Transport‑Provider Model)

**Concept**  
A digital marketplace + logistics platform connecting:  
Farmers → Retailers → Consumers  
Delivering fresh, affordable, traceable farm products directly from source.

---

## 1. Core Principles

- No owned fleet – Delivery is performed by independent, registered transport providers (motorbikes, pickups, lorries, vans, etc.).
- Three‑sided marketplace – Farmers | Buyers (retailers + consumers) | Transport providers.
- Traceability – Every product batch is linked to a specific farmer and harvest date.
- Fair pricing – Farmers see suggested market prices; buyers see transparent markups.
- Escrow‑based payments – Buyer funds are held securely by the platform (via M‑Pesa PayBill collection account) until delivery is confirmed, then released to farmer and transport provider via M‑Pesa B2C.

---

## 2. The Problem We Solve

| Stakeholder | Problem |
|-------------|---------|
| Farmers | Rely on brokers → low profits |
| Retailers | Inconsistent supply |
| Consumers | High prices, low freshness |
| Entire chain | Fragmented, no transparency in pricing or sourcing |

---

## 3. Our Solution

MAMBONAMI provides:
- Direct farmer access to markets
- Real‑time ordering system
- Integrated logistics (pickup + delivery)
- Transparent pricing & product traceability

---

## 4. User Roles & Registration Data

| Role | Required Info | Verification |
|------|---------------|--------------|
| Farmer | Full name, ID number, farm location (GPS), product categories, bank/M‑Pesa number | Phone OTP + **cooperative endorsement (required, with waiver for unaffiliated farmers)** |
| Retailer | Business name, physical shop address, PIN (if registered) | Business permit upload (future) |
| Consumer | Name, delivery address(es), phone number | Phone OTP |
| **Transport Provider** | Full name, ID, **vehicle type** (motorbike/pickup/lorry/van), **vehicle registration**, **driver’s license**, photo | Background check (manual first), liability waiver, **real deposit of KES 500 via M‑Pesa PayBill** |

**Cooperative endorsement update (critical gap fix):**  
- Cooperative endorsement is **required** for farmers, but we allow a waiver for truly unaffiliated farmers (e.g., they sign an affidavit).  
- For cooperative-endorsed farmers: platform verifies by calling the cooperative’s published phone number or receiving a digital letter.  
- Store `coop_verified = true/false` – `true` farmers receive higher trust score and priority listing.  
- Future: API integration with SACCO systems.

**Transport provider deposit update (critical gap fix):**  
- Transport provider must **actually send KES 500 via M-Pesa** to PayBill `123456` with Account Number `DEP-TRANSPORT-{provider_id}`.  
- Money sits in PayBill float as a real deposit. When provider leaves in good standing, platform refunds via B2C.  
- Deposit discourages fake acceptances and provides compensation for fraud.

Transport providers are independent contractors – they set their own availability (daily max deliveries, preferred working area, vehicle type) and accept/decline delivery jobs.

---

## 5. Product Categories & Units

| Code | Category | Examples | Base Unit |
|------|----------|----------|------------|
| MA | Matunda (fruits) | mango, banana, orange, avocado | kg / piece |
| MBO | Mboga (vegetables) | sukuma wiki, spinach, cabbage, tomato | kg / bunch |
| NA | Nafaka (grains) | maize, beans, rice, lentils | kg |
| MI | Mizizi (roots) | potato, cassava | kg |
| MI | Miche (seedlings) | tree seedlings, vegetable seedlings | piece |
| MI | Mifugo (livestock products) | eggs (tray), milk (litre), chicken (whole), goat | litre / tray / piece |

Farmer rule: One product listing = one category + unit + price per unit + available quantity + harvest/pack date.

---

## 6. Order & Delivery Logic (Transport‑mediated, Escrow Payments via PayBill)

### 6.1 Order Placement (Buyer side)
- Buyer adds items from one or multiple farmers to cart.  
- System splits cart into farmer‑specific sub‑orders.  
- Buyer chooses:  
  - Delivery date & time window (same‑day or next‑day)  
  - Payment method: M‑Pesa PayBill (only option for MVP) – buyer pays the full amount upfront.  
- Platform calculates:  
  - Subtotal (farmer price × quantity)  
  - Service fee (commission, % of subtotal – buyer visible)  
  - **Delivery fee** (see 6.3 below)  
- Payment instruction to buyer:  
  *“Pay KES XXXX to PayBill 123456, Account Number [ORDER-XXXXXX]”*  
  (Account Number unique per order, e.g., `ORD-12345` or `INV-2024001`.)

### 6.2 What Happens After Buyer Pays
**Step A – Safaricom processes the payment:**  
- Buyer sends money to PayBill 123456 with the generated Account Number.  
- Safaricom debits buyer’s M‑Pesa wallet.  
- Money enters Safaricom’s PayBill holding ledger (a “bucket” for MAMBONAMI’s merchant account). It is not yet in our bank account.

**Step B – Instant callback (IPN) to MAMBONAMI:**  
- Safaricom sends a real‑time POST request to our API endpoint:  
  `POST https://api.mambonami.com/mpesa/callback`  
- Payload includes: `TransactionCode`, `Amount`, `AccountNumber` (the order ID), `PhoneNumber`, `Time`.  
- **Idempotency check (critical gap fix):**  
  - Before processing, check if `TransactionCode` already exists in `mpesa_callbacks` table.  
  - If exists → return `200 OK` and do nothing.  
  - If new → proceed to mark order as PAID.  

**Step C – Platform records escrow:**  
- The money is now logically held by MAMBONAMI in Safaricom’s merchant ledger – but we treat it as escrow.  
- Funds are not yet available for withdrawal to our bank account; they remain in the PayBill collection account.

**Crucial escrow reality:**  
Safaricom is not the escrow agent. MAMBONAMI acts as escrow agent by:  
- Tracking the money in the PayBill ledger.  
- Only authorising delivery after payment is confirmed.  
- Later initiating B2C payouts to farmers and transport providers.  
- No direct reverse from PayBill – refunds are done via B2C.

### 6.3 Farmer Order Fulfillment
After payment callback is received and order is marked as “Paid – in escrow”:  
1. Farmer receives order notification (in-app + WhatsApp) – list of items, quantity, pickup deadline.  
2. Farmer must confirm or reject within 30 min (auto‑cancel if no response).  
   - If cancelled, system initiates a refund via B2C (see Section 7.5).  
3. If accepted, farmer prepares goods and indicates **“ready for pickup”** in app.  
4. **Transport provider** is automatically notified (only after farmer marks ready).

### 6.4 Transport Matching & Fee Logic (No‑fleet model)
- **Delivery fee is dynamic:**  
  - Base fee (per km from farm cluster → buyer location)  
  - Waiting time surcharge if farmer delays >15 min after transport arrival  
  - Bulky item surcharge (e.g., 50+ kg) – also based on vehicle type (lorries can charge more)  
- **Transport provider receives 80% of delivery fee** – platform keeps 20% for payment processing & support.  
- Provider can accept or decline a pickup offer (visible: distance, items, estimated pay).  
- If no provider accepts within 10 min, platform:  
  1. Re‑offers with +10% fee  
  2. After second failure, notifies admin to manually assign via WhatsApp group (fallback).  
- Providers set their vehicle type and capacity; the system only offers orders that fit (e.g., lorry for bulky orders).

### 6.5 Delivery State Machine

Order Placed → Paid (Escrow) → Farmer Confirmed → Farmer Ready → Transport Assigned → Transport Picked Up → Delivered
↓ (reject/timeout) ↓ (decline) ↓ (issue)
Cancelled Re‑offer to others Escalate to support


### 6.6 Proof of Delivery & Escrow Release (Payout) – **UPDATED with OTP flow**
**Concrete OTP delivery confirmation (critical gap fix):**  
1. Transport provider arrives at buyer’s location → clicks **“Deliver”** in app.  
2. App generates a random **4-digit OTP** (e.g., `8421`) – valid for **5 minutes**.  
3. Provider shows OTP to buyer.  
4. Buyer enters OTP into **provider’s app** OR their own app (depending on UI).  
5. OTP entry triggers **mandatory photo capture** (geo‑tagged) of delivered goods.  
6. If OTP expires, provider must request a new OTP (max 3 attempts).  

- Buyer also has option to report an issue within 2 hours (see dispute resolution).  
- If buyer confirms delivery via OTP (or 2 hours pass without complaint):  
  - Platform triggers B2C payouts from its PayBill merchant account:  
    - Farmer payout = subtotal – platform commission  
    - **Transport provider payout = delivery fee share (80%)**  
  - Both payouts are sent to the registered M‑Pesa numbers within minutes.  
  - These B2C payments are real outgoing transfers from MAMBONAMI’s PayBill float (money collected earlier).  
- If buyer reports an issue, no payout is made – funds remain in the PayBill ledger (still held as escrow) until resolved by support (see Section 10).

**Without OTP, providers can fake deliveries. This flow eliminates that risk.**

---

## 7. M‑Pesa PayBill Integration & Escrow Mechanics (Detailed)

### 7.1 PayBill Setup
- MAMBONAMI will apply for a PayBill number (e.g., `123456`) from Safaricom.  
- Required: Business registration, director KYC, tax compliance, nature of business (agricultural marketplace – low risk).  
- The PayBill is linked to a merchant account (ledger at Safaricom) – money settles to our business bank account daily/weekly.  

**Critical float management update (see also Section 17.1)** – We do not rely on bank settlement for payouts; we keep sufficient float for B2C by maintaining a reserve floor.

### 7.2 Collection Flow (Buyer → Platform)
| Step | Description |
|------|-------------|
| 1 | Buyer initiates payment in app. App displays: PayBill 123456, Acc No: ORD-12345, Amount KES 1,000. |
| 2 | Buyer pays via M‑Pesa (Lipa Na M-Pesa → PayBill). |
| 3 | Safaricom debits buyer. Funds enter MAMBONAMI PayBill ledger (held by Safaricom). |
| 4 | Safaricom sends IPN callback to our server with transaction details. |
| 5 | Our system verifies the Account Number matches a pending order and applies idempotency. |
| 6 | Order status changes to Paid (Escrow). Money is now logically “held” by platform. |

### 7.3 Reconciliation: How We Match Payments to Orders
- Every order gets a unique Account Number format: `ORD-{order_id}` or `INV-{order_id}`.  
- The IPN callback provides exactly that Account Number.  
- No manual matching needed – fully automated.

### 7.4 Payout Flow (Platform → Farmer / Transport Provider) – B2C API
When delivery is confirmed:  
1. Platform calls Safaricom B2C API (Business to Customer) from the same PayBill.  
2. B2C transfers money from our PayBill float directly to the farmer’s M‑Pesa number.  
3. Similarly, transport provider receives their delivery fee via B2C.  
4. These are instant transfers (real-time), not dependent on bank settlement.  

**Important – Float management (critical gap fix):**  
- The money collected via PayBill stays in Safaricom’s ledger.  
- We are allowed to send B2C payments from that float as long as we maintain sufficient balance.  
- **To prevent settlement draining the float overnight, we will:**  
  - Maintain a reserve floor of **KES 200,000** in the PayBill float.  
  - Work with Safaricom to set a **manual settlement threshold** (e.g., settle only amount above KES 200,000).  
  - Alternatively, apply for a **Safaricom Merchant Overdraft** to cover temporary gaps.  
- Settlement to our bank account happens separately (e.g., daily) and is used for operations, not payouts.

### 7.5 Refunds (Cancellations / Disputes)
Since a PayBill cannot reverse a transaction:  
- Buyer cancellation before farmer confirms:  
  - Platform initiates a B2C refund to the buyer’s M‑Pesa number from the PayBill float.  
  - Deduct a 10% cancellation fee if after 5 minutes – that fee stays as platform revenue.  
- Dispute resolution (buyer wins partial refund):  
  - Platform pays buyer via B2C from the float, and adjusts the farmer’s payout accordingly (deduct from farmer’s future earnings or from held amount if not yet paid).  
- No “reverse PayBill” – all refunds are outbound B2C payments.

### 7.6 Settlement to Bank Account (Not for Payouts)
- Safaricom settles the PayBill ledger balance to our business bank account daily/weekly.  
- This settlement is **not** used for payouts – payouts come directly from the PayBill float as described in 7.4.  
- The bank account is for operations, salaries, and reserves.

### 7.7 Fees (Safaricom + Platform)
- Safaricom charges a PayBill transaction fee (e.g., ~1% + KES 5) – deducted from each collection.  
- B2C payouts also incur a small fee (e.g., KES 10–30 per transaction).  
- Our platform adds its own commission (8–12%) on top of the farmer’s price.  
- The buyer sees the total (farmer price + commission + delivery fee + Safaricom fees).

---

## 8. Pricing & Commission Rules

| Transaction component | Platform cut | Recipient |
|----------------------|--------------|-----------|
| Product sale (subtotal) | 8% (MVP) → scales to 12% | Farmer (92% of subtotal) |
| Delivery fee | 20% | **Transport provider (80% of fee)** |
| Late pickup penalty (if farmer delays >30 min after transport arrival) | 100% penalty paid by farmer, added to provider’s pay | Transport provider |

Penalty rules are clearly shown to farmers before they confirm an order. Penalty amount is deducted from farmer’s future escrow payout.  
Safaricom PayBill & B2C fees are borne by the platform (operational cost).

---

## 9. Transport Provider Registration & Performance Logic – **UPDATED with real deposit**

- Provider signs up → uploads documents (**vehicle type, registration, driver’s license**) → **pays a real refundable deposit of KES 500 via M-Pesa PayBill** (Account Number `DEP-TRANSPORT-{provider_id}`).  
  - Deposit money sits in PayBill float, tracked in platform ledger.  
  - Deposit returned via B2C when provider leaves with good standing (no unresolved disputes, no fraud).  
- Provider receives a rating (1–5 stars) from buyers and farmers.  
- Low rating (<2.5) → suspended after 3 reports.  
- High rating (4.5+) → priority offer matching (gets first refusal on nearby pickups).  
- Providers can set: daily max orders, preferred working area (sub‑county), **vehicle type** (motorbike, pickup, lorry, van).  

**Why real deposit is critical (gap fix):**  
Without a real deposit, bad providers can create new accounts after fraud. The deposit provides financial disincentive and a source of compensation if a provider disappears with goods.

---

## 10. Dispute Resolution (Escrow Context)

| Dispute type | Process |
|--------------|---------|
| Buyer says goods not fresh / wrong quantity | Buyer must upload photo within 2 hours of delivery. Platform reviews. If valid: partial refund (e.g., 50% of product cost) via B2C from escrow float. Farmer pays penalty (deducted from future earnings). |
| Farmer says transport never came | Check transport provider GPS trail + timestamp of “arrived at farm” button. If never arrived, provider gets zero delivery fee and may be suspended. Escrow refunds delivery fee portion to buyer via B2C. |
| Provider claims they delivered but buyer disputes | Requires photo + OTP confirmation. If photo matches but buyer still disputes, platform can split difference if both parties have high ratings. Split paid via B2C. |
| Order never delivered (provider disappears) | Platform uses provider’s real deposit (KES 500) to partially compensate farmer. Buyer gets full escrow refund via B2C. Provider banned. |

All escrow holds are released only after dispute is resolved by admin decision. Refunds are always B2C from the PayBill float.

---

## 11. Special Business Rules (MVP)

- Minimum order value: KES 200 for delivery (no pickup option in MVP).  
- Maximum order horizon: 3 days ahead (farmers post available harvest up to 3 days in advance).  
- Cancellation by buyer:  
  - Free within 5 minutes of payment (full B2C refund).  
  - After 5 minutes but before farmer confirms → 10% cancellation fee deducted, rest refunded via B2C.  
  - After farmer confirms → buyer forfeits 50% of product subtotal (paid to farmer as compensation), delivery fee fully refunded via B2C.  
- Batch traceability: Every product listing must have harvest date. Buyers see “remaining shelf life: X days”.  
- Cooperative override: If a farmer misses 3 confirmed orders in a month, their cooperative (if any) is notified to provide training.

---

## 12. Reporting & Analytics (Internal / Admin)

- Daily: escrow balance (PayBill ledger view), farmer payouts (B2C total), **transport provider earnings**, commission collected.  
- Weekly: average time from “farmer ready” to “transport assigned” (provider density metric), dispute rate.  
- Monthly: top 10 farmers by sales per category (MA/MBO/NA/MI), top transport providers by completed deliveries.

---

## 13. Revenue Model (How We Earn)

| Source | Details |
|--------|---------|
| Commission per sale | 8–12% of product subtotal |
| Delivery fee share | 20% of each delivery fee |
| Subscription plans (future) | Premium farmers/retailers pay monthly for analytics & priority listing |
| Featured listings (ads) | Farmers pay to appear at top of category search |

---

## 14. Competitive Advantage

- Direct sourcing – cuts out middlemen → better farmer earnings & buyer prices  
- Fresher produce (harvest dates visible, shorter supply chain)  
- Strong category identity (MAMBONAMI = easy to remember)  
- Local‑first approach (Kenya‑focused, supports smallholder farmers)  
- Escrow via PayBill + instant B2C payouts ensures trust and speed  
- **Any transport provider can participate** – from boda bodas to lorry owners, increasing coverage for bulk orders

---

## 15. Go‑To‑Market Strategy (Kenya Focus)

**Launch region:** Nairobi + Kiambu / Nyeri / Murang’a farms  

**Partnerships:**  
- Farmer cooperatives (SACCOs) – to onboard farmers in groups  
- Local market vendor associations – to recruit retailers  
- **Transport provider associations** (e.g., boda boda SACCOS, lorry owner groups)  

**Growth channels:**  
- WhatsApp groups  
- Referral bonuses (e.g., KES 100 per successful transaction from new user)  
- Influencer marketing (food vendors, cooking influencers)  

**MVP success metrics (3 months):**  
- 100 active farmers  
- 500 buyers  
- **50 registered transport providers** (mix of motorcycles, pickups, vans)  
- 1,000 completed orders  

---

## 16. Future Logic Extensions (Phase 2)

- **Batching:** One transport provider picks from multiple nearby farms → split delivery fee. Escrow handles split B2C payouts.  
- **Cold chain premium:** Farmer pays for cold‑bag rental → can set +15% price.  
- **Farmer credit:** After 50 successful deliveries, farmer qualifies for input loans (deducted from future escrow payouts via B2C).  
- **B2B supply to supermarkets** – dedicated retailer dashboard with bulk ordering & invoice system.  
- **Agro‑input marketplace** – farmers buy seeds, fertiliser on platform (PayBill collection, B2C payouts to sellers).  
- **Processing & branding** – packaging produce under MAMBONAMI brand for export.  
- **Vehicle‑specific routing** – match bulky orders with lorries/pickups, small orders with motorcycles.

---

## 17. Critical Gaps & Solutions (Pre‑Development Checklist)

*This section must be reviewed and implemented before any production deployment.*

### 17.1 The "PayBill Float" Funding Risk (Most Dangerous)

**Problem:**  
You assume you can pay farmers/transport providers via B2C immediately from the float. But Safaricom settles the PayBill float to your bank account daily (usually at midnight). If you send B2C payments after settlement, you might have zero float.

**Example:**  
- Buyer pays KES 1,000 at 10:00 PM → float has KES 1,000  
- Safaricom settles float to your bank at 11:59 PM → float becomes KES 0  
- Delivery completes at 7:00 AM next day → B2C fails (insufficient float)

**Solution:**  
- Maintain a **reserve floor** in the PayBill float (e.g., KES 200,000).  
- Work with Safaricom and your bank to set a **manual settlement threshold** (e.g., settle only amount above KES 200,000).  
- Apply for a **Safaricom Merchant Overdraft** to cover temporary gaps.  
- **Fallback:** If float is low, queue B2C payouts and process them after next collection (but this hurts UX).  

**Action item:** Before launch, confirm with Safaricom that you can delay settlement or keep a reserve.

### 17.2 Missing Idempotency for IPN Callbacks

**Problem:**  
Safaricom may send the same IPN multiple times (network retries). Your system will double-mark orders as PAID and trigger double payouts.

**Solution:**  
Create an idempotency table and check before processing each callback.

```sql
CREATE TABLE mpesa_callbacks (
    transaction_code VARCHAR(50) PRIMARY KEY,
    order_id INT,
    processed_at TIMESTAMP,
    UNIQUE KEY (transaction_code)
);

In your IPN handler:

text
IF transaction_code already exists:
    RETURN 200 OK (do nothing)
ELSE:
    Process payment, mark order PAID
Action item: Implement this before integrating the IPN endpoint.

17.3 Buyer OTP for Delivery Confirmation is Vague
Problem:
Original doc says "obtain buyer’s verbal or in‑app confirmation (e.g., an OTP shared by buyer)". This is not specific enough and will cause disputes.

Concrete OTP flow (already integrated into Section 6.6):

Transport provider arrives at buyer’s location → clicks “Deliver” in app.

App generates random 4-digit OTP (valid 5 minutes).

Provider shows OTP to buyer.

Buyer enters OTP into provider’s app (or their own app).

OTP entry triggers mandatory photo capture (geo‑tagged).

OTP expires after 5 minutes → provider must request new OTP.

Action item: Build this exact flow. Without it, providers will fake deliveries.

17.4 Cooperative Endorsement is Not Verifiable
Problem:
“Optional cooperative endorsement” means nothing if you can't verify it.

Solution (already integrated into Section 4):

Make cooperative endorsement required but allow a waiver for unaffiliated farmers.

For cooperative-endorsed farmers: Verify by calling cooperative’s published phone number or receiving a digital letter.

Store coop_verified = true/false – true farmers get higher trust score.

Action item: Build a simple verification workflow for admin to mark cooperative status.

17.5 Transport Provider Deposit is Not Actually Held
Problem:
Original doc says “deposit is held in escrow (recorded in platform ledger, not actually transferred)”. This means the provider never paid – so they have no incentive to behave well.

Solution (already integrated into Sections 4 and 9):
Transport provider must actually send KES 500 via M-Pesa to PayBill 123456 with Account Number DEP-TRANSPORT-{provider_id}. That money sits in the float as a real deposit. When provider leaves, you B2C refund it.

Action item: Implement deposit collection during provider onboarding. Do not activate provider until deposit is confirmed via IPN.

Summary: PayBill vs Previous Assumption
Aspect	What we previously thought	Reality (now in doc + gaps fixed)
Payment method	M‑Pesa (generic)	PayBill number + unique Account Number
Where money sits	“Platform escrow account”	Safaricom PayBill ledger (platform has no direct bank access until settlement)
Real‑time confirmation	Assumed instant	Yes – via IPN callback with idempotency
Payout to farmer	“Release from escrow”	B2C API from PayBill float (requires reserve floor)
Refunds	“Reverse transaction”	B2C outpayment (cannot reverse PayBill)
Bank settlement	Used for payouts	Only for operations; payouts come from PayBill float
Transport provider deposit	Ledger entry only	Real M-Pesa payment (KES 500)
Delivery confirmation	Verbal or vague OTP	Concrete 4-digit OTP + mandatory photo
Cooperative endorsement	Optional, unverified	Required with verification process
Vehicle type	Not considered	Full support for motorcycles, pickups, lorries, vans
Document version: 1.3 – PayBill-Ready + Transport‑Provider Model
Status: Ready for implementation – development must address all items in Section 17 before launch.