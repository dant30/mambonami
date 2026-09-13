# Mambonami Landing Site & Platform Architecture

**Last Updated**: 2026-09-11

---

## Executive Summary

Mambonami should operate as a **two-layer platform**:

1. **Public Marketplace Layer** — The commercial front door, accessible to all visitors (authenticated or not)
2. **Authenticated Business Workspaces** — Role-specific operating areas for buyers, farmers, retailers, and transport providers

The `/home` route is **not** a generic dashboard. It's the **public commercial landing page** that doubles as marketplace discovery.

---

## ✅✅ IMPLEMENTATION PROGRESS

**Current Status**: Phase 1 marketplace foundation, Phase 2 authentication/routing, Phase 3 farmer workspace core, Phase 4 buyer workspace core, Phase 5 retailer workspace core, Phase 6 transport workspace core, and Phase 7 navigation implemented

### ✅✅ Completed (Frontend)
- AuthContext.tsx — Secure token management (memory + HttpOnly cookies)
- private.tsx — Role-based routing with `/app/{role}` pattern
- App.tsx — App initialization with session restoration
- LoginPage.tsx — Post-login redirect to `/app/{role}`
- Header.tsx — Role-aware navigation (guest/buyer/farmer/retailer/transport/admin)
- Sidebar.tsx — Role-specific menu with `/app/{role}` paths
- Footer.tsx — Updated dashboard links to `/app/{role}`
- MobileBottomNav.tsx — Mobile navigation with role-specific tabs
- Farmer workspace — Dashboard, products, product form, orders, and earnings pages
- Buyer workspace — Dashboard, product discovery, orders, active orders, order details, cart, wishlist, and checkout pages
- Retailer workspace — Procurement dashboard, products, purchase orders, suppliers, and invoices pages
- Transport workspace — Operations dashboard, available jobs, active/completed trips, trip controls, and earnings pages

### 🔄 Phase 1 Follow-up Polish
Completed: guest wishlist migration after authentication, server-backed pagination, category presentation, organic filtering, sorting, price/rating filtering, stock filtering, and product reviews. Remaining: none for the Phase 1 follow-up polish.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Public Marketplace Layer](#public-marketplace-layer)
3. [Authenticated Workspaces](#authenticated-workspaces)
4. [Post-Authentication Flow](#post-authentication-flow)
5. [Role-Specific Implementations](#role-specific-implementations)
6. [Navigation Structure](#navigation-structure)
7. [Implementation Checklist](#implementation-checklist)
8. [Technical Considerations](#technical-considerations)
9. [Key Principles](#key-principles)
10. [Summary](#summary)
11. [**CRITICAL: Registration Flow — Challenge-Based Architecture**](#15-registration-flow-challenge-based-architecture-not-password-in-state)
12. [**CRITICAL: SplashPage Architecture**](#155-splashpage-visual-layer-only-not-authentication-logic)
13. [Preserve User's Intended Destination](#16-even-better-preserve-the-users-intended-destination)
14. [Visitor Wishlist Management](#17-wishlist-needs-similar-treatment)
15. [Homepage Design](#18-your-home-page-should-sell-mambonami-and-sell-products)
16. [Role-Based Headers](#19-the-header-should-change-based-on-authentication)
17. [Shared Layout System](#20-architectural-recommendation-shared-layout-system)
18. [Complete User Journey](#21-the-final-mambonami-journey)

---

## Architecture Overview

### Platform Structure

```
                    MAMBONAMI
                       │
          ┌────────────┴────────────┐
          │                         │
     PUBLIC MARKETPLACE        AUTHENTICATED
          │                         │
          │                  ROLE BUSINESS AREAS
          │                         │
    /home                    ┌──────┼──────┬──────┐
    /products                │      │      │      │
    /product/:id          /buyer  /farmer /retailer /transport
    /how-it-works            │      │      │      │
    /about                   └──────┴──────┴──────┘
    /support
    /cart
    /wishlist
    /checkout (auth required)
```

### Mental Model

- **Public Layer**: Visitor discovery and commerce
- **Authenticated Layer**: Business operations and management
- **Admin Layer**: Platform administration (`/admin/...`)

---

## Public Marketplace Layer

### Purpose

The public marketplace is the **commercial front door** of Mambonami.

A visitor arriving at `/home` should immediately understand:
- **What is Mambonami?**
- **What can I buy?**

### Public Header Navigation

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  [MAMBONAMI LOGO]  How It Works | Products | About         │
│                    For Farmers | For Businesses | Support  │
│                                                             │
│                        [🔍 Search]                          │
│                    [♡ Wishlist] [🛒 Cart]                  │
│                    [Login] [Get Started]                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Mobile** — Collapse into hamburger menu with same navigation items.

### Public Routes

| Route | Purpose | Auth Required | Features |
|-------|---------|---------------|----------|
| `/home` | Public marketplace & brand landing | ❌ No | Featured products, hero, value proposition |
| `/products` | Product listing & discovery | ❌ No | Search, filters, categories, sorting |
| `/product/:id` | Product detail page | ❌ No | Description, images, farmer/supplier info, reviews, pricing |
| `/wishlist` | Saved products (persistent after login) | ❌ No | Can view; save to `localStorage` (merge on login) |
| `/cart` | Shopping cart (persistent after login) | ❌ No | Can view/manage; stored in `localStorage` (merge on login) |
| `/checkout` | Checkout & payment | ✅ **Yes** | Requires authentication to complete purchase |
| `/how-it-works` | How Mambonami works | ❌ No | Educational content, platform explanation |
| `/about` | About Mambonami | ❌ No | Company story, values, team |
| `/support` | Help & support | ❌ No | FAQ, contact, resources |

### Visitor Capabilities

✅ A visitor **can** do:

- Browse products by category
- Search products
- Filter products (price, availability, rating, etc.)
- View product details
- View farmer/supplier information
- View reviews and ratings
- Add products to cart
- Remove products from cart
- Change quantities in cart
- Wishlist products
- View saved wishlist
- Learn how Mambonami works
- Read about Mambonami
- Contact support
- Begin registration flow

❌ A visitor **cannot** do:

- Complete checkout (must authenticate)
- Place an order
- Permanently save wishlist (not persistent without auth)
- Access account/profile
- View order history
- Participate in business workflows

### Cart & Wishlist Strategy

**Cart**: Stored in `localStorage` for visitors.
- Survives page refreshes
- Survives browser close
- **Merged into authenticated cart after login**
- Old cart tokens can be abandoned

**Wishlist**: Stored in `localStorage` for visitors.
- Survives page refreshes
- **Migrated to user account after login**
- User can also add to wishlist while authenticated (persists on account)

This is standard marketplace practice (e.g., Amazon, Jumia).

---

## Authenticated Workspaces

After login, the user is directed to a **role-specific workspace**.

Each workspace is a **business operating area**, not a generic dashboard.

### Post-Login Routing

```
                    LOGIN
                      │
                      ▼
            ┌─────────────────────┐
            │ Authenticate User   │
            └────────────┬────────┘
                         │
                         ▼
            ┌─────────────────────┐
            │  Determine Role     │
            └────────────┬────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
      buyer            farmer          retailer
        │                │                │
        ▼                ▼                ▼
    /app/buyer/       /app/farmer/     /app/retailer/
    dashboard         dashboard        dashboard
        
        ▼ (if applicable)
    transport_provider
        │
        ▼
   /app/transport/
   dashboard
```

**Do NOT** send all users to `/orders`.

✅✅ **Route Architecture**: Use `/app/{role}` prefix to clearly separate the authenticated application from the public marketplace.

---

## Post-Authentication Flow

### Authentication Requirements Met

After successful authentication:

1. **User object is set** in `AuthContext`
2. **Access token stored** in `localStorage`
3. **Refresh token stored** in `localStorage`
4. **Role is determined** from user object
5. **Destination is calculated** based on role + onboarding status

### Routing Logic

```typescript
// determinePostLoginDestination(user, onboardingStatus)

if (user.role === 'buyer') {
  return '/app/buyer';
}

if (user.role === 'farmer') {
  return '/app/farmer';
}

if (user.role === 'retailer') {
  return '/app/retailer';
}

if (user.role === 'transport_provider') {
  return '/app/transport';
}

if (user.role === 'admin') {
  return '/app/admin';
}

// Fallback
return '/home';
```

✅✅ **Architecture**: Post-login redirects to `/app/{role}` which is the authenticated workspace.

---

## Role-Specific Implementations

### 1. FARMER WORKSPACE

**Purpose**: Help farmers **sell their products**.

**Primary CTA**: **+ Add Product** (supply is the engine)

#### Dashboard Intent

```
Good morning, John!

Your farm business

┌───────────────────────────────┐
│ Orders Received               │
│ 24                            │
└───────────────────────────────┘

┌───────────────────────────────┐
│ Active Products               │
│ 18                            │
└───────────────────────────────┘

┌───────────────────────────────┐
│ Monthly Sales                 │
│ KSh 84,500                    │
└───────────────────────────────┘

┌───────────────────────────────┐
│ Pending Orders                │
│ 7                             │
└───────────────────────────────┘

Recent Orders
────────────────────────────────
#MN-10293 | Tomatoes | KSh 4,500 | Pending delivery
#MN-10292 | Potatoes | KSh 3,200 | Delivered
#MN-10291 | Onions   | KSh 2,100 | Collected

My Products
────────────────────────────────
Tomatoes       [Active]   [5 orders]
Potatoes       [Active]   [3 orders]
Onions         [Low stock] [1 order]

[ + Add Product ]
```

#### Route Structure

```
/app/farmer                       — Dashboard/overview
/app/farmer/orders                — Orders received
/app/farmer/orders/:id            — Order details
/app/farmer/products              — Product listings
/app/farmer/products/new          — Create product
/app/farmer/products/:id          — Product details
/app/farmer/products/:id/edit     — Edit product
/app/farmer/sales                 — Sales summary
/app/farmer/earnings              — Earnings/payments
/app/farmer/analytics             — Analytics & insights
/app/farmer/messages              — Buyer/logistics messages
/app/farmer/notifications         — Notifications center
/app/farmer/profile               — Profile management
/app/farmer/settings              — Account settings
```

#### Navigation Items

```
Dashboard
Orders Received
My Products
Sales
Earnings
Analytics
Messages
Notifications
Profile
Settings
```

#### Key Features

- **Product Management**: Create, edit, delete products
- **Inventory Tracking**: Stock levels, alerts
- **Order Management**: View orders, mark as collected, delivery tracking
- **Earnings**: Payment history, balance, withdrawal
- **Analytics**: Sales trends, top products, buyer patterns
- **Communication**: Direct messaging with buyers/transporters

---

### 2. BUYER WORKSPACE

**Purpose**: Help buyers **find and purchase products**.

**Platform Feel**: Shopping application (not accounting system)

#### Dashboard Intent

```
Good morning, Jane!

Your marketplace

[ Search products... ]

Categories
Vegetables | Fruits | Cereals | Dairy | Meat

Recommended for you
────────────────────────────────

Recent Orders
────────────────────────────────
#MN-10290 | 2 kg Tomatoes | Delivered on Sept 8
#MN-10289 | 5 kg Potatoes | Delivered on Sept 5

Active Orders
────────────────────────────────
#MN-10295 | Tomatoes, Onions | Out for delivery

Your Wishlist
────────────────────────────────
Organic Carrots (10 items)
Free-range Eggs (2 items)
```

#### Route Structure

```
/app/buyer                        — Dashboard/overview
/app/buyer/products               — Product discovery (search, filter)
/app/buyer/product/:id            — Product details
/app/buyer/orders                 — Order history
/app/buyer/orders/:id             — Order details
/app/buyer/active-orders          — Active/pending orders
/app/buyer/cart                   — Shopping cart
/app/buyer/wishlist               — Saved products
/app/buyer/addresses              — Delivery addresses
/app/buyer/payments               — Payment methods
/app/buyer/profile                — Profile management
/app/buyer/settings               — Account settings
```

#### Navigation Items

```
Dashboard
Browse Products
Orders
Active Orders
Cart
Wishlist
Saved Addresses
Payments
Profile
Settings
```

#### Key Features

- **Product Discovery**: Search, filter by category, price, rating, availability
- **Supplier Information**: View farmer/supplier details, ratings, reviews
- **Ordering**: Add to cart, checkout, payment
- **Order Tracking**: Real-time status updates, delivery tracking
- **Wishlist**: Save products, add to cart from wishlist
- **Reviews**: Rate products and suppliers
- **Messages**: Contact sellers/transporters

---

### 3. RETAILER WORKSPACE

**Purpose**: Serve as a **business customer procurement platform**.

**Business Model**: Bulk buying, recurring orders, supplier relationships

#### Dashboard Intent

```
Good morning, ABC Retailers!

Business Procurement

Monthly Purchases
KSh 245,000

Open Orders
12

Suppliers
18

Pending Deliveries
5

[ Find Products ]

Recent Purchases
────────────────────────────────
Tomatoes | 50 kg | KSh 12,500 | Sept 8
Potatoes | 25 kg | KSh 8,750  | Sept 7

Preferred Suppliers
────────────────────────────────
Green Farm Co. | 12 orders | Last order: Sept 8
Fresh Valley   | 8 orders  | Last order: Sept 5

Reorder (from previous purchases)
────────────────────────────────
Tomatoes (50 kg) | KSh 12,500 | [Reorder]
```

#### Route Structure

```
/app/retailer                     — Dashboard/overview
/app/retailer/products            — Product discovery
/app/retailer/product/:id         — Product details
/app/retailer/orders              — Order history
/app/retailer/orders/:id          — Order details
/app/retailer/suppliers           — Supplier management
/app/retailer/suppliers/:id       — Supplier details
/app/retailer/purchases           — Purchase history
/app/retailer/recurring-orders    — Recurring/subscription orders
/app/retailer/cart                — Shopping cart
/app/retailer/analytics           — Business analytics
/app/retailer/invoices            — Invoice history
/app/retailer/team                — Team management (future)
/app/retailer/profile             — Business profile
/app/retailer/settings            — Business settings
```

#### Navigation Items

```
Dashboard
Browse Products
Suppliers
Orders
Purchases
Recurring Orders
Cart
Analytics
Invoices
Team (if multi-user)
Profile
Settings
```

#### Key Features

- **Product Discovery**: Advanced filtering, price comparison, bulk pricing
- **Supplier Management**: Favorites, ratings, communication
- **Bulk Ordering**: Quantity discounts, bulk pricing tiers
- **Recurring Orders**: Set up repeat purchases on schedule
- **Purchase History**: Full audit trail, invoicing
- **Analytics**: Spending trends, supplier performance, reorder patterns
- **Team Management** (future): Multiple staff accounts, approval workflows
- **Credit/Financing** (future): Payment terms, credit lines, financing options

**Future Expansion**:
- B2B pricing tiers
- Volume discounts
- Credit facilities
- Vendor financing
- POS integration
- Multi-location management

---

### 4. TRANSPORT PROVIDER WORKSPACE

**Purpose**: Manage **delivery operations and logistics**.

**Platform Feel**: Operations/logistics dashboard

#### Dashboard Intent

```
Good morning, David!

Delivery Operations

Availability
🟢 Available

Today's Jobs
8

Completed
6

Earnings Today
KSh 5,800

Pending Jobs
2

Available Delivery Jobs
────────────────────────────────
Job #MN-2031
From: Green Farm Co.
To: ABC Retailers
Distance: 18 km
Payment: KSh 1,200
[Accept Job]

Job #MN-2030
From: Fresh Valley
To: Nairobi Central Market
Distance: 12 km
Payment: KSh 900
[Accept Job]

Active Delivery
────────────────────────────────
Job #MN-2029
Status: In transit
Vehicle: KCN XXX
Route: Starting point → Destination
Estimated arrival: 2:30 PM
[View Details]
```

#### Route Structure

```
/app/transport                    — Dashboard/overview
/app/transport/jobs               — Available jobs
/app/transport/jobs/:id           — Job details
/app/transport/jobs/:id/track     — Active job tracking
/app/transport/active-jobs        — Jobs in progress
/app/transport/completed-jobs     — Completed jobs
/app/transport/earnings           — Earnings summary
/app/transport/earnings/withdrawals — Payment history
/app/transport/vehicles           — Vehicle management
/app/transport/vehicles/:id       — Vehicle details
/app/transport/availability       — Set availability status
/app/transport/routes             — Historical routes
/app/transport/ratings            — Driver ratings & reviews
/app/transport/messages           — Job-related messages
/app/transport/profile            — Driver profile
/app/transport/settings           — Account settings
```

#### Navigation Items

```
Dashboard
Available Jobs
Active Jobs
Completed Jobs
Earnings
Vehicles
Availability
Routes
Ratings
Messages
Profile
Settings
```

#### Key Features

- **Job Management**: View available jobs, accept jobs, track active deliveries
- **GPS Tracking**: Real-time location tracking, navigation
- **Earnings**: Track earnings per job, daily/weekly/monthly totals
- **Ratings & Reviews**: Driver rating system, feedback from customers
- **Vehicle Management**: Track vehicle info, maintenance, fuel
- **Availability**: Toggle availability, set working hours
- **Messaging**: Communicate with dispatch, customers, pickup/drop points
- **History**: Track all completed deliveries, routes, earnings history

---

## Navigation Structure

### Public Navigation (Unauthenticated)

**Header**:
```
[MAMBONAMI LOGO]

How It Works | Products | About | For Farmers | For Businesses | Support

[🔍 Search] [♡ Wishlist] [🛒 Cart] [Login] [Get Started]
```

**Footer**:
```
Products | How It Works | About | Support | Contact
Careers | Blog | Press | Privacy | Terms
```

**Mobile**: Hamburger menu collapses all items

### Authenticated Navigation

Each role has a **persistent sidebar** (desktop) or **bottom tab bar** (mobile).

#### Sidebar (Desktop)

```
┌─────────────────────────┐
│ [LOGO] [User Profile]   │
├─────────────────────────┤
│ Dashboard               │
│ [Role-specific items]   │
│ [Role-specific items]   │
│ Messages                │
│ Notifications           │
│ Profile                 │
│ Settings                │
│ Help                    │
│ Logout                  │
└─────────────────────────┘
```

#### Bottom Tab Bar (Mobile)

```
┌─────────────────────────────────────────┐
│ Dashboard | Browse | Orders | Menu      │
│           (role-specific second tab)    │
└─────────────────────────────────────────┘
```

### Header (Authenticated)

**Always present**:
- Logo → Home (public marketplace, not dashboard)
- Search
- Notifications
- User menu (Profile, Settings, Logout)
- Mobile hamburger

---

## Implementation Checklist

### Phase 1: Public Marketplace Foundation ✅✅ CORE IMPLEMENTATION COMPLETE

- [x] Create `/home` page
  - [x] Hero section with value proposition
  - [x] Featured products section
  - [ ] Category grid
  - [x] Call-to-action buttons
  - [ ] Social proof/testimonials

- [x] Implement `/products` page
  - [x] Product grid/list view
  - [x] Search functionality
  - [x] Category, organic, and sorting filters
  - [x] Sorting options
  - [x] Pagination

- [x] Implement `/product/:id` page
  - [x] Product images
  - [x] Product description
  - [x] Pricing information
  - [x] Stock status
  - [x] Farmer/supplier info card
  - [x] Rating summary when supplied by the API
  - [x] Review list and submission flow
  - [x] Add to cart button
  - [x] Add to wishlist button
  - [x] Related products

- [x] Implement `/cart` page
  - [x] Cart items list
  - [x] Quantity adjustment
  - [x] Remove items
  - [x] Cart subtotal
  - [x] Checkout button (routes to login if unauthenticated)
  - [x] localStorage persistence

- [x] Implement `/wishlist` page
  - [x] Saved products list
  - [x] Remove guest items from wishlist
  - [x] Add to cart from wishlist
  - [x] localStorage persistence
  - [x] Migration to account after login

- [x] Implement static pages
  - [x] `/how-it-works`
  - [x] `/about`
  - [x] `/support`

### Phase 2: Authentication & Routing ✅✅ COMPLETE

- [x] Secure JWT configuration
  - [x] Update `JWT_SECRET_KEY` to 32+ bytes
  - [x] Configure `SIMPLE_JWT` signing key
  - [x] Test token generation and validation

- [x] Implement role-based routing
  - [x] Create `PrivateRoute` wrapper
  - [x] Create `AdminRoute` wrapper
  - [x] Implement `determinePostLoginDestination()` logic
  - [x] Test routing for all roles

- [x] Implement post-login redirect
  - [x] Buyer → `/app/buyer`
  - [x] Farmer → `/app/farmer`
  - [x] Retailer → `/app/retailer`
  - [x] Transport → `/app/transport`
  - [x] Admin → `/app/admin`

✅✅ **Route Structure Updated**: All authenticated routes now use `/app/{role}` pattern

### Phase 3: Farmer Workspace ✅✅ CORE IMPLEMENTATION COMPLETE

- [x] Create `/app/farmer` dashboard
  - [x] Key metrics (orders, products, sales)
  - [x] Recent orders list
  - [x] Active products list
  - [x] + Add Product CTA

- [x] Create `/app/farmer/products`
  - [x] Product list view
  - [x] Edit/delete actions
  - [x] Stock level indicators

- [x] Create `/app/farmer/products/new`
  - [x] Product form
  - [x] Image upload
  - [x] Category selection
  - [x] Pricing

- [x] Create `/app/farmer/orders`
  - [x] Orders list
  - [ ] Order filters
  - [x] Order details view
  - [x] Order status updates
  - [ ] Delivery tracking

- [x] Create `/app/farmer/earnings`
  - [x] Revenue summary
  - [x] Payment history
  - [ ] Withdrawal requests

### Phase 4: Buyer Workspace ✅✅ CORE IMPLEMENTATION COMPLETE

- [x] Create `/app/buyer` dashboard
  - [x] Personalized greeting
  - [x] Product discovery CTA
  - [x] Recent orders
  - [x] Active order summary
  - [x] Wishlist preview

- [x] Create `/app/buyer/products` (authenticated version)
  - [x] Product discovery grid
  - [x] Search
  - [x] Category filtering
  - [x] Advanced price/rating/availability filters
  - [x] Sorting options

- [x] Create `/app/buyer/orders`
  - [x] Order history
  - [x] Order status tracking
  - [ ] Reorder functionality

- [x] Create `/app/buyer/active-orders`
  - [x] Active order filtering

- [x] Create `/app/buyer/orders/:id`
  - [x] Order detail view
  - [x] Delivery progress timeline

- [x] Create `/app/buyer/cart`
  - [x] Persistent cart view and quantity management
  - [x] Checkout flow
  - [ ] Authenticated cart merge API
  - [ ] Payment integration

- [x] Create `/app/buyer/wishlist`
  - [x] Account wishlist view
  - [x] Add-to-cart workflow

- [x] Create `/app/buyer/checkout`
  - [x] Delivery details
  - [x] Order creation request
  - [ ] Payment integration

### Phase 5: Retailer Workspace ✅✅ CORE IMPLEMENTATION COMPLETE

- [x] Create `/app/retailer` dashboard
  - [x] Business metrics
  - [x] Purchase summary
  - [x] Supplier summary
  - [ ] Reorder options

- [x] Create `/app/retailer/suppliers`
  - [x] Supplier directory derived from marketplace supply
  - [ ] Ratings and reviews
  - [x] Contact information when supplied by the API
  - [ ] Order history per supplier

- [x] Create `/app/retailer/orders`
  - [x] Purchase order history
  - [ ] Bulk ordering interface
  - [ ] Recurring order setup

- [x] Create `/app/retailer/invoices`
  - [x] Invoice list from purchase order records
  - [ ] Invoice details
  - [ ] Export/download

### Phase 6: Transport Provider Workspace ✅✅ CORE IMPLEMENTATION COMPLETE

- [x] Create `/app/transport` dashboard
  - [x] Available job count
  - [x] Active trip metrics
  - [x] Completed delivery metrics
  - [x] Earnings summary
  - [x] Availability toggle

- [x] Create `/app/transport/jobs`
  - [x] Available jobs list
  - [x] Job details
  - [x] Accept job functionality
  - [x] Decline job functionality with provider-specific persistence

- [x] Create `/app/transport/active-jobs`
  - [x] Active trips list
  - [x] Trip status progress
  - [x] Pickup/delivery action controls
  - [x] Live GPS tracking map and server location pings

- [x] Create `/app/transport/completed-jobs`
  - [x] Completed trip history

- [x] Create `/app/transport/earnings`
  - [x] Earnings summary
  - [x] Payment history
  - [ ] Withdrawal requests

- [x] Create `/app/transport/vehicles`
  - [x] Vehicle type, capacity, plate, and driver-license management
  - [x] Vehicle data used by assignment snapshots

### Phase 7: Navigation Updates ✅✅ COMPLETE

- [x] Update Header component
  - [x] Public vs authenticated states
  - [x] Role-aware navigation
  - [x] Mobile responsive

- [x] Update Sidebar component
  - [x] Role-specific menu items
  - [x] Active state highlighting
  - [x] Responsive behavior

- [x] Update Footer component
  - [x] Public vs authenticated states
  - [x] Role-aware links

- [x] Update Mobile Navigation
  - [x] Bottom tab bar implementation
  - [x] Role-specific tabs
  - [x] Active state

### Phase 8: Testing & Polish ✅ Core Coverage Implemented

- [x] End-to-end authentication handoff
  - [x] Checkout preserves the intended destination when login is required
  - [x] Protected and admin routes preserve direct destinations
  - [x] Role-specific dashboard routing remains covered by the existing route contract
  - [x] Concurrent 401 responses share one token refresh request

- [x] Cart persistence and checkout safety
  - [x] Guest cart persists in localStorage across updates
  - [x] Auth transitions preserve the shared local cart
  - [x] Successful order creation clears the cart
  - [x] Failed order creation keeps the cart available for retry

- [x] Wishlist persistence and migration
  - [x] Guest wishlist persists in localStorage
  - [x] Successful guest items migrate after authentication
  - [x] Failed server migrations remain available locally for retry

- [x] Responsive validation
  - [x] Desktop marketplace smoke coverage
  - [x] Mobile marketplace overflow check
  - [x] Checkout and fixed navigation surfaces are included in browser smoke coverage

- [x] Accessibility polish
  - [x] Auth labels are programmatically associated with inputs
  - [x] Invalid auth fields expose `aria-invalid`
  - [x] Header menus expose expanded/controlled state and close on Escape

#### Phase 8 Verification Commands

From `landing/`:

```bash
npm install
npx playwright install --with-deps chromium
npm run test
npm run test:e2e
npm run build
npm run lint
```

Unit and integration coverage lives in `landing/tests/`; responsive browser checks live in `landing/tests/e2e/`. Browser tests mock API responses so they can validate the frontend without requiring a running backend.

---

## Technical Considerations

### 1. Token Management

**Storage Strategy** (Production Architecture):
- **Access Token**: Short-lived (15-60 min) stored in memory (JS variable)
  - Automatically cleared on page refresh or browser close
  - Sent in Authorization header for API requests
  - Minimal XSS attack surface

- **Refresh Token**: Long-lived (7-14 days) in HttpOnly + Secure + SameSite cookie
  - Not accessible to JavaScript (prevents XSS theft)
  - Automatically sent with requests (browser handles it)
  - Survives page refresh and browser close
  - Backend rotates token on each refresh (SimpleJWT `ROTATE_REFRESH_TOKENS`)

**Validation**:
- Check access token exists in memory before API calls
- On 401 response: Initiate token refresh using refresh cookie
- On refresh failure: Clear session and redirect to login
- Refresh token rotates on each use (old token invalidated)

**Security**:
- Use HTTPS in production (required for secure cookies)
- CORS properly configured with `credentials: 'include'`
- SameSite=Strict for CSRF protection
- Secure flag ensures HTTPS-only transmission

✅✅ **Token Architecture**: Access token in memory (short-lived), refresh token in HttpOnly cookie (long-lived) to minimize XSS vulnerability impact.

### 2. Route Guards

**Public Routes**: No authentication needed
```typescript
<Route path="/" element={<LandingPage />} />
<Route path="/home" element={<HomePage />} />
<Route path="/products" element={<ProductsPage />} />
<Route path="/product/:id" element={<ProductDetailPage />} />
<Route path="/login" element={<LoginPage />} />
<Route path="/register" element={<RegisterPage />} />
```

**Private Routes**: Require authentication (under `/app` prefix)
```typescript
<PrivateRoute path="/app/buyer" element={<BuyerDashboard />} />
<PrivateRoute path="/app/farmer" element={<FarmerDashboard />} />
<PrivateRoute path="/app/retailer" element={<RetailerDashboard />} />
<PrivateRoute path="/app/transport" element={<TransportDashboard />} />
```

**Admin Routes**: Require admin role
```typescript
<AdminRoute path="/app/admin" element={<AdminDashboard />} />
```

### 3. API Architecture

**Public Endpoints**:
- `GET /api/products` — List products
- `GET /api/products/:id` — Product details
- `GET /api/categories` — Product categories
- `POST /api/auth/register` — User registration
- `POST /api/auth/login` — User login

**Authenticated Endpoints**:
- `GET /api/user/profile` — Current user info
- `POST /api/orders` — Create order
- `GET /api/orders` — User's orders (role-filtered)
- `POST /api/cart` — Cart operations
- Role-specific endpoints per workspace

### 4. Authentication Context

**useAuth() Hook**:
```typescript
{
  isAuthenticated: boolean,
  user: User | null,
  role: string | null,
  access_token: string | null,
  refresh_token: string | null,
  login: (credentials) => Promise<void>,
  logout: () => void,
  setSession: (tokens, user) => void,
  refreshToken: () => Promise<void>
}
```

### 5. State Management

**AuthContext**:
- User authentication state
- Token management
- Login/logout/refresh logic

**Per-Role State** (consider Context or Zustand):
- Dashboard data (orders, products, etc.)
- Filters and search state
- Cart/wishlist state (for buyers)

### 6. Performance Optimization

**Code Splitting**:
- Lazy load role-specific workspaces
- Lazy load product pages
- Lazy load admin features

**Caching**:
- Cache product listings
- Cache user profile
- Cache category data
- Use SWR or React Query for data fetching

**Image Optimization**:
- Use Next.js Image (if migrating)
- Or Vite image optimization
- Lazy load product images

### 7. Responsive Design

**Breakpoints**:
- Mobile: < 640px
- Tablet: 640px - 1024px
- Desktop: > 1024px

**Navigation**:
- Mobile: Bottom tab bar
- Tablet: Side drawer (collapsible)
- Desktop: Full sidebar

**Layouts**:
- Public pages: Stacked mobile-first
- Authenticated workspaces: Dashboard grid layout

### 8. Accessibility

**WCAG 2.1 AA Compliance**:
- Semantic HTML
- ARIA labels where needed
- Keyboard navigation
- Color contrast (4.5:1 for text)
- Focus indicators
- Alt text for images

### 9. Error Handling

**Token Errors**:
- `401 Unauthorized`: Refresh token
- `403 Forbidden`: Redirect to unauthorized page
- `TokenExpired`: Auto-refresh or redirect to login

**API Errors**:
- Display user-friendly error messages
- Log errors for debugging
- Retry logic for transient failures

### 10. Internationalization (i18n)

**Planned for future**:
- Support multiple languages
- Locale-based routing (optional)
- Translated product names/descriptions
- Localized pricing and currency

---

## Key Principles

### 1. **Separation of Concerns**

Public marketplace is distinct from authenticated workspaces.

### 2. **Discovery First**

Visitors should be able to browse and explore without forced registration.

### 3. **Role-Based Experience**

Each role gets a workspace tailored to their business needs.

### 4. **Persistent Cart & Wishlist**

localStorage-backed cart/wishlist merge into authenticated account.

### 5. **Clear Navigation**

Users always know where they are and how to navigate.

### 6. **Mobile-First**

Design for mobile first, enhance for desktop.

### 7. **Performance**

Fast page loads, optimized images, lazy loading.

### 8. **Security**

Strong JWT keys, token rotation, HTTPS in production.

---

## Summary

Mambonami operates as a **three-layer platform**:

1. **Public Marketplace** — `/home`, `/products`, `/cart`, `/wishlist`
2. **Authenticated Workspaces** — Role-specific business areas (under `/app`)
3. **Admin** — Platform management (`/app/admin`)

The key architectural insight:

> **Do not route everyone to `/orders`. Route by role to business-specific workspaces using `/app/{role}` pattern.**

This creates a cleaner, more maintainable, and ultimately more valuable platform for each user type.

---

## 15. Registration Flow: Challenge-Based Architecture (NOT Password in State)

**Critical Security Principle**: Never pass sensitive data (passwords, OTPs) through React Router state or URL parameters.

### Registration Flow with Challenge ID

Instead of:

```typescript
// ❌ WRONG - password exposed in state
navigate('/otp', {
  state: {
    registration: {
      phone,
      role,
      password,
      email,
    }
  }
})
```

Do:

```
Registration Page
       ↓
POST /api/auth/registration/start
  (phone, email, role)
       ↓
Backend creates registration_challenge_id
  (stored in session/DB with TTL)
       ↓
Return: {
  challengeId: "challenge_xyz_123",
  message: "OTP sent to phone",
  phone: "+254712345678" (last 4 digits masked)
}
       ↓
OTP Verification Page
  (only needs challengeId)
       ↓
POST /api/auth/registration/verify
  (challengeId, otp, password)
       ↓
Backend validates:
  - Challenge exists and not expired
  - OTP matches
  - Password meets requirements
       ↓
Success: {
  access_token,
  refresh_token,
  user: { id, role, name, ... }
}
       ↓
Login complete, redirect to /app/{role}
```

### Implementation

**Step 1: Registration Start**

```typescript
// RegistrationPage.tsx
const handleSubmit = async (formData) => {
  const response = await api.post('/api/auth/registration/start', {
    phone: formData.phone,
    email: formData.email,
    role: formData.role,
  })
  
  // challengeId is the ONLY thing stored in state
  setChallenge({
    id: response.data.challengeId,
    phone: response.data.phone,
  })
  
  navigate('/registration/verify', {
    state: {
      challengeId: response.data.challengeId,
      // NO PASSWORD, NO EMAIL, NO OTP
    }
  })
}
```

**Step 2: OTP Verification**

```typescript
// VerificationPage.tsx
const handleVerify = async (otp, password, confirmPassword) => {
  const challengeId = location.state?.challengeId
  
  const response = await api.post('/api/auth/registration/verify', {
    challengeId,
    otp,
    password,
  })
  
  // Store tokens securely
  setAccessToken(response.data.access_token) // memory
  setCookie('refreshToken', response.data.refresh_token) // HttpOnly cookie
  
  // Set auth context
  setUser(response.data.user)
  
  navigate(`/app/${response.data.user.role}`, { replace: true })
}
```

**Step 3: Backend Registration Start Endpoint**

```python
# registration/start
POST /api/auth/registration/start

Request:
{
  "phone": "+254712345678",
  "email": "farmer@example.com",
  "role": "farmer"
}

Response:
{
  "challengeId": "challenge_abc_123_xyz",
  "message": "OTP sent to +254712345678",
  "phone": "+254712345678",
  "expiresIn": 300  # 5 minutes
}

Backend:
1. Validate phone format
2. Check phone not already registered
3. Create RegistrationChallenge:
   {
     id: "challenge_abc_123_xyz",
     phone: "+254712345678",
     email: "farmer@example.com",
     role: "farmer",
     otp: "123456" (sent to SMS),
     created_at: now(),
     expires_at: now() + 5 min,
     verified: False
   }
4. Send OTP via SMS
5. Return challengeId (no sensitive data)
```

**Step 4: Backend Verification Endpoint**

```python
# registration/verify
POST /api/auth/registration/verify

Request:
{
  "challengeId": "challenge_abc_123_xyz",
  "otp": "123456",
  "password": "SecurePassword123!"
}

Response:
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": {
    "id": 123,
    "phone": "+254712345678",
    "role": "farmer",
    "email": "farmer@example.com",
    "isOnboarded": False
  }
}

Backend:
1. Retrieve RegistrationChallenge by challengeId
2. Verify not expired
3. Verify OTP matches
4. Validate password strength
5. Create User account:
   {
     phone: "+254712345678",
     email: "farmer@example.com",
     password_hash: hash(password),
     role: "farmer",
     created_at: now(),
     isOnboarded: False
   }
6. Mark challenge as verified
7. Issue tokens (JWT)
8. Return tokens + user data (no password)
```

### Benefits

✅ **No password in React state** — Sensitive data stays on backend

✅ **No password in URL** — Challenge ID is the only state

✅ **Automatic cleanup** — Challenge expires after 5 minutes

✅ **Replay protection** — Challenge ID is single-use (verified, then marked)

✅ **Backend control** — OTP validation happens only on server

✅ **Audit trail** — Full registration history in DB

✅ **Rate limiting** — Can rate-limit by phone, challengeId, etc.

\u2705\u2705 **Registration Security**: Challenge-based flow separates registration from authentication, never exposing sensitive data in client-side state.

---

## 15.5 SplashPage: Visual Layer Only (NOT Authentication Logic)

**Critical Architectural Decision**: Your SplashPage should be purely visual. It should **NOT** determine authentication, check user role, or orchestrate routing.

### Wrong Approach (Current)

```
SplashPage
     ↓
Check localStorage for token
     ↓
Determine user role
     ↓
Decide which dashboard to show
     ↓
/farmer, /buyer, etc.
```

**Problems**:
- Authentication logic tangled with branding
- Race conditions (tokens loading while splash displays)
- XSS vulnerability — checking tokens in JS on first load
- Complicated redirect logic in splash component

### Correct Approach

```
App Boots
  ↓
AuthContext Provider initializes
  ↓
Restore session from storage/cookies
  ↓
Set isAuthenticated, user, role
  ↓
Render Routes
  ↓
  ├─ If authenticated → protected routes check role → /app/{role}
  └─ If not authenticated → SplashPage (3 sec) → /home
```

### Implementation

**1. App.tsx — Bootstrap Authentication**

```typescript
// App.tsx
function App() {
  const [isInitialized, setIsInitialized] = useState(false)
  const { restoreSession } = useAuth()
  
  useEffect(() => {
    // Restore session on app boot
    // Check HttpOnly cookie + memory token
    // Set user, role, authenticated state
    const init = async () => {
      await restoreSession()
      setIsInitialized(true)
    }
    init()
  }, [])
  
  // Don't render anything until auth is restored
  if (!isInitialized) {
    return <LoadingScreen /> // minimal, invisible
  }
  
  return <Routes />
}
```

**2. Routes.tsx — Authentication Awareness**

```typescript
// routes.tsx
function Routes() {
  const { isAuthenticated, user } = useAuth()
  
  return (
    <BrowserRouter>
      <Switch>
        {/* Public routes */}
        <Route path="/" element={<LandingPage />} />
        <Route path="/home" element={<HomePage />} />
        <Route path="/products" element={<ProductsPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        
        {/* Authenticated splash → home */}
        <Route path="/splash" element={
          isAuthenticated ? <Navigate to={`/app/${user.role}`} /> : <Navigate to="/home" />
        } />
        
        {/* Protected routes */}
        <Route
          path="/app/buyer/*"
          element={isAuthenticated && user.role === 'buyer' ? <BuyerApp /> : <Navigate to="/login" />}
        />
        <Route
          path="/app/farmer/*"
          element={isAuthenticated && user.role === 'farmer' ? <FarmerApp /> : <Navigate to="/login" />}
        />
        
        {/* ... other roles ... */}
      </Switch>
    </BrowserRouter>
  )
}
```

**3. SplashPage — Pure Visual Component**

```typescript
// SplashPage.tsx
export function SplashPage() {
  useEffect(() => {
    // 3 second splash, then navigate
    const timer = setTimeout(() => {
      navigate('/home')
    }, 3000)
    
    return () => clearTimeout(timer)
  }, [])
  
  return (
    <div className="splash-container">
      <div className="logo">MAMBONAMI</div>
      <p>Fresh food. Closer to home.</p>
      {/* Just visual, no logic */}
    </div>
  )
}
```

**4. AuthContext.restoreSession()**

```typescript
// AuthContext.tsx
const AuthContext = createContext()

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [accessToken, setAccessToken] = useState(null)
  
  const restoreSession = async () => {
    try {
      // Check if refresh token exists in HttpOnly cookie
      // (browser automatically includes it with requests)
      
      // Try to refresh tokens
      const response = await api.post('/api/auth/refresh', {})
      
      setAccessToken(response.data.access_token)
      setUser(response.data.user)
      setIsAuthenticated(true)
    } catch (error) {
      // No valid session
      setIsAuthenticated(false)
      setUser(null)
    }
  }
  
  return (
    <AuthContext.Provider value={{ user, isAuthenticated, accessToken, restoreSession }}>
      {children}
    </AuthContext.Provider>
  )
}
```

### Benefits

✅ **Separation of concerns** — Splash is visual only

✅ **Clean routing** — Routes determine auth, splash doesn't

✅ **No race conditions** — Auth fully restored before rendering

✅ **Security** — Auth logic isolated, not in component

✅ **Maintainability** — Splash can be redesigned without touching auth

✅ **Testability** — Auth can be tested independently

### User Journey (Correct)

```
User visits mambonami.com
      ↓
App boots, AuthContext restores session
      ↓
Session check completes
      ↓
  ├─ If authenticated → Routes render protected routes → /app/{role}
  │
  └─ If not authenticated → /home shown
                ↓
            SplashPage (optional, 3 sec)
                ↓
            /home (or /products, /about, etc.)
```

\u2705\u2705 **SplashPage Architecture**: Visual component only. Authentication restored at app boot by AuthContext provider, before routes render.

---

## 16. Even Better: Preserve the User's Intended Destination

There's another important case.

Suppose a visitor does:

```
/home
  ↓
Product detail
  ↓
Add to cart
  ↓
Checkout
  ↓
Authentication required
  ↓
Login
```

You don't want to dump them into `/buyer` and make them hunt for checkout.

Instead:

```
Checkout
   ↓
Authentication required
   ↓
Login
   ↓
Successful authentication
   ↓
Return to checkout
```

### Implementation: `returnTo` Pattern

Your auth system should support a `returnTo` state:

```typescript
// In checkout page, when auth is required
navigate('/login', {
  state: {
    returnTo: '/checkout',
  },
})
```

Then after login:

```typescript
// In LoginPage or AuthContext
const returnTo = location.state?.returnTo

navigate(returnTo || getRoleHome(user.role), {
  replace: true,
})
```

### Benefits

✅ Visitor completes their intended action (checkout)

✅ No friction — they don't have to navigate back to checkout

✅ Better conversion rate — reduces abandonment

✅ Professional experience — same as Amazon, Shopify, etc.

### Common `returnTo` Destinations

- `/checkout` — From cart
- `/product/:id` — From product details
- `/products` — From product search
- `/wishlist` — From wishlist
- Role dashboard fallback — If no `returnTo` specified

---

## 17. Wishlist Needs Similar Treatment

You can actually let **unauthenticated visitors wishlist**.

Store temporary wishlist in `localStorage`:

```typescript
// Guest wishlists in localStorage
localStorage.setItem('guestWishlist', JSON.stringify([
  { productId: '123', name: 'Tomatoes', addedAt: '2026-09-11T10:30:00Z' },
  { productId: '456', name: 'Potatoes', addedAt: '2026-09-11T10:35:00Z' },
]))
```

After login, **merge guest wishlist into server wishlist**:

```typescript
// In AuthContext or after successful login
const guestWishlist = JSON.parse(localStorage.getItem('guestWishlist') || '[]')

// Merge with server wishlist
if (guestWishlist.length > 0) {
  await api.post('/api/wishlist/merge', {
    items: guestWishlist,
  })
  localStorage.removeItem('guestWishlist')
}
```

### Benefits

✅ Visitors can build a wishlist before registering

✅ Wishlist survives page refresh and browser close

✅ Wishlist persists across devices after login (merged to account)

✅ **Gives visitors a reason to interact with the marketplace**

✅ Reduces friction to login — they already have a wishlist to save

### Wishlist Feature: Personalization

Once merged, wishlist becomes a powerful conversion tool:

- Email reminders: "Tomatoes you wishlisted are now in stock"
- Price drops: "Your wishlisted potatoes dropped by KSh 500"
- Recommendations: "People who wishlisted X also bought Y"
- Quick reorder: "Re-add all wishlisted items to cart"

---

## 18. Your Home Page Should Sell Mambonami AND Sell Products

The homepage is not just a landing page. It's also a **marketplace discovery page**.

### Recommended Homepage Layout

```
┌──────────────────────────────────────────────────┐
│ MAMBONAMI                                        │
│ How It Works  Products  About                    │
│                            Login  Get Started    │
└──────────────────────────────────────────────────┘

          FRESH FOOD.
          CLOSER TO HOME.

      Discover fresh produce directly
      from Kenyan farmers and suppliers.

         [Shop Fresh Produce]

               ↓

           Featured Products

   ┌────────┐ ┌────────┐ ┌────────┐
   │ Tomato │ │ Potato │ │ Onion  │
   │ KSh 45 │ │ KSh 30 │ │ KSh 25 │
   │ [♡]    │ │ [♡]    │ │ [♡]    │
   │ [+Cart]│ │ [+Cart]│ │ [+Cart]│
   └────────┘ └────────┘ └────────┘

               ↓

         Browse Categories

   Vegetables | Fruits | Cereals | Dairy

               ↓

         How Mambonami Works

        ┌─────┐  ┌─────┐  ┌─────┐
        │Farm │→ │Market│→ │Buy  │
        └─────┘  └─────┘  └─────┘
                      ↓
                 Delivery

               ↓

         For Farmers
         Sell your produce. Build your business.

         [Become a Farmer]

               ↓

         For Businesses
         Source agricultural products at scale.

         [Join as a Retailer]

               ↓

         Why Mambonami?

       ✓ Direct from farmers
       ✓ Secure transactions
       ✓ Reliable delivery
       ✓ Fair pricing

               ↓

            Footer
```

### Homepage Content Strategy

**Hero Section**:
- Value proposition (fresh, direct, local)
- Search functionality
- CTA to shop or browse

**Featured Products**:
- Show bestsellers
- Seasonal/in-season products
- High-quality images
- Price visibility
- Quick add-to-cart

**Categories**:
- Visual grid of product categories
- Browse without registering

**Social Proof**:
- Number of farmers
- Number of buyers
- Total orders
- Customer reviews

**Educational Content**:
- How it works (simple 3-step explanation)
- For farmers (recruitment section)
- For businesses (B2B section)

**Trust Signals**:
- Secure transactions badge
- Verified farmers
- Customer ratings
- Money-back guarantee

**Call-to-Actions**:
- Shop now
- Become a farmer
- Join as retailer
- Get started

---

## 19. The Header Should Change Based on Authentication

Headers should be **radically different** depending on whether the visitor is authenticated and their role.

### Guest Header

```
┌────────────────────────────────────────────────────┐
│ MAMBONAMI                                          │
│                                                    │
│ Home  Products  How It Works  About  Support       │
│                                                    │
│                        [🔍 Search]                 │
│                   [♡ Wishlist] [🛒 Cart]          │
│                   [Login] [Get Started]            │
└────────────────────────────────────────────────────┘
```

### Buyer Header

```
┌────────────────────────────────────────────────────┐
│ MAMBONAMI                                          │
│                                                    │
│ Shop  Orders  Wishlist                             │
│                                                    │
│                        [🔍 Search]                 │
│                     [🛒 Cart]                      │
│              [🔔 Notifications]                    │
│              [👤 Jane Doe ▾]                       │
└────────────────────────────────────────────────────┘
```

### Farmer Header

```
┌────────────────────────────────────────────────────┐
│ MAMBONAMI                                          │
│                                                    │
│ Dashboard  Orders  My Products  Sales  Analytics   │
│                                                    │
│              [🔔 Notifications]                    │
│              [👤 John Farmer ▾]                    │
└────────────────────────────────────────────────────┘
```

### Retailer Header

```
┌────────────────────────────────────────────────────┐
│ MAMBONAMI                                          │
│                                                    │
│ Dashboard  Shop  Orders  Suppliers  Purchases      │
│                                                    │
│                    [🔍 Search]                     │
│              [🔔 Notifications]                    │
│         [👤 ABC Retailers ▾]                       │
└────────────────────────────────────────────────────┘
```

### Transport Provider Header

```
┌────────────────────────────────────────────────────┐
│ MAMBONAMI                                          │
│                                                    │
│ Dashboard  Delivery Jobs  Active  Vehicles         │
│                                                    │
│            Availability: 🟢 Online                 │
│              [🔔 Notifications]                    │
│              [👤 David ▾]                          │
└────────────────────────────────────────────────────┘
```

### Key Insight

Each header **tells the user exactly what they can do** without cluttering with irrelevant options.

- Guest: Explore and learn
- Buyer: Shop and manage orders
- Farmer: Manage supply and earnings
- Retailer: Manage procurement
- Transporter: Manage delivery jobs

---

## 20. Architectural Recommendation: Shared Layout System

**Do NOT** duplicate the entire application shell for every role.

Instead, use a **layout composition pattern**:

```typescript
// Two main layouts

<PublicLayout>
  {/* Public marketplace pages */}
  <HomePage />
  <ProductsPage />
  <ProductDetailPage />
</PublicLayout>

<BusinessLayout>
  {/* Authenticated role-specific pages */}
  <FarmerDashboard />
  <BuyerDashboard />
  <RetailerDashboard />
</BusinessLayout>
```

### PublicLayout

```
┌──────────────────────────────────┐
│        Public Header              │
├──────────────────────────────────┤
│                                  │
│          Page Content            │
│                                  │
├──────────────────────────────────┤
│         Public Footer             │
└──────────────────────────────────┘
```

### BusinessLayout

```
┌──────────────────────────────────┐
│      Business Header              │
├─────────────┬────────────────────┤
│             │                    │
│  Sidebar    │                    │
│             │   Page Content     │
│ (injected   │                    │
│  nav)       │                    │
│             │                    │
├─────────────┴────────────────────┤
│         Footer                    │
└──────────────────────────────────┘
```

### Implementation

```typescript
// Navigation configuration
const farmerNavigation = [
  { label: 'Dashboard', path: '/farmer/dashboard' },
  { label: 'Orders', path: '/farmer/orders' },
  { label: 'My Products', path: '/farmer/products' },
  { label: 'Sales', path: '/farmer/sales' },
  { label: 'Analytics', path: '/farmer/analytics' },
]

const buyerNavigation = [
  { label: 'Dashboard', path: '/buyer/dashboard' },
  { label: 'Shop', path: '/products' },
  { label: 'Orders', path: '/buyer/orders' },
  { label: 'Wishlist', path: '/buyer/wishlist' },
]

// Usage
<BusinessLayout 
  navigation={farmerNavigation}
  headerType="farmer"
>
  <FarmerDashboard />
</BusinessLayout>

<BusinessLayout 
  navigation={buyerNavigation}
  headerType="buyer"
>
  <BuyerDashboard />
</BusinessLayout>
```

### Benefits

✅ **Single source of truth** for shell components (Header, Sidebar, Footer)

✅ **Consistency** across all roles (same spacing, colors, typography)

✅ **Maintainability** — Update header once, affects all roles

✅ **Flexibility** — Role-specific navigation injected as props

✅ **Performance** — Components reused, not duplicated

✅ **Accessibility** — Consistent keyboard navigation, ARIA labels

---

## 21. The Final Mambonami Journey

Here's the complete user journey **from splash to business operations**:

### Complete Mambonami Flow

```
                    ┌────────────────┐
                    │     APP        │
                    │    BOOTS       │
                    └────────┬───────┘
                             │
            ┌────────────────┴────────────────┐
            │                                 │
      Restore session                    No session
     (auth context init)                     │
            │                                 ▼
            ▼                              SplashPage
    ┌─────────────────┐                  (3 seconds)
    │ Session found?  │                     │
    └────────┬────────┘                     ▼
             │                            /home
      ┌──────┴──────┐
      │             │
     YES            NO
      │              │
      ▼              ▼
 Authenticated   Public Marketplace
      │              │
      ├─────┬────────┼────────┬────────┐
      │     │        │        │        │
   /app/  Products Wishlist Cart  Checkout
   {role}  │        │        │        │
      │    ▼        ▼        ▼        ▼
      └→ Details  Save   Manage   Auth Required
                                       │
                                       ▼
                                    Login
                                       │
                            ┌──────────┴──────────┐
                            │                     │
                        Successful          Cancelled
                        Auth                Login
                            │                     │
                            ▼                     ▼
                   returnTo || Dashboard      /home
                   (e.g., /checkout)
                            │
                            ▼
                      Complete Action
                   (e.g., place order)
```

### Guest → Checkout → Auth → Complete Purchase

```
Guest browses /home
    ↓
Clicks product
    ↓
Views /product/:id
    ↓
Adds to cart
    ↓
Views /cart
    ↓
Clicks Checkout
    ↓
Redirected to /login with returnTo=/checkout
    ↓
Logs in or registers
    ↓
AuthContext sets user, role, tokens
    ↓
Returns to /checkout
    ↓
Completes payment
    ↓
Placed order ✓
    ↓
Redirected to /app/buyer
```

✅✅ **Navigation**: Post-checkout redirects to `/app/{role}` automatically

### Guest Wishlist → Login → Merge

```
Guest browses
    ↓
Adds product to wishlist
    ↓
Wishlist stored in localStorage
    ↓
Guest browses more products
    ↓
Decides to save wishlist permanently
    ↓
Clicks "Save Wishlist" → /login
    ↓
Logs in
    ↓
AuthContext merges guestWishlist + serverWishlist
    ↓
Redirected to /app/buyer
    ↓
Wishlist persisted to account
```

### Farmer Journey

```
Unauthenticated farmer visits /home
    ↓
Clicks "For Farmers"
    ↓
Views farmer information section
    ↓
Clicks "Become a Farmer"
    ↓
Registration flow (challenge-based, no password in state)
    ↓
Redirected to /app/farmer
    ↓
Sets up profile
    ↓
Clicks "+ Add Product"
    ↓
Creates first product
    ↓
Product goes live on marketplace
    ↓
Waits for orders
```

### Retailer Journey

```
Unauthenticated retailer visits /home
    ↓
Clicks "For Businesses"
    ↓
Views B2B information
    ↓
Clicks "Join as a Retailer"
    ↓
Registration flow (challenge-based, no password in state)
    ↓
Redirected to /app/retailer
    ↓
Can immediately start browsing products
    ↓
Can view bulk pricing
    ↓
Places first bulk order
```

### Transport Provider Journey

```
Unauthenticated provider visits /home
    ↓
Clicks "Become a Delivery Partner" (if shown)
    ↓
Registration flow (challenge-based, no password in state)
    ↓
Redirected to /app/transport
    ↓
Sets up profile & vehicle info
    ↓
Toggles availability to 🟢 Online
    ↓
Available jobs appear
    ↓
Accepts first job
    ↓
Starts delivery operations
```

---

## The Complete Mental Model

### Three Distinct User Experiences

**1. Public Marketplace Experience**

```
Visitor-first, discovery-focused
  ├── Browse without friction
  ├── No forced login
  ├── Cart persists (localStorage)
  ├── Wishlist persists (localStorage)
  └── Auth only when needed (checkout)
```

**2. Authenticated Buyer Experience**

```
Shopping platform
  ├── Fast checkout
  ├── Order history
  ├── Wishlist management
  ├── Delivery tracking
  └── Product reviews
```

**3. Authenticated Business Experiences**

```
Farmer
  ├── Supply management
  ├── Order fulfillment
  ├── Earnings tracking
  └── Customer communication

Retailer
  ├── Procurement at scale
  ├── Supplier management
  ├── Business analytics
  └── Invoicing

Transport Provider
  ├── Job dispatch
  ├── Route optimization
  ├── GPS tracking
  └── Earnings management
```

---

## Why This Architecture Works

### 1. **Visitor-First Design**

Mambonami treats all arrivals as potential **customers first**.

No gatekeeping. No friction. Browse, explore, fall in love with tomatoes, **then** create an account.

### 2. **Progressive Engagement**

```
Visitor → Interested → Account-holder → Active participant
```

Each step increases commitment without forcing it upfront.

### 3. **Role Clarity**

Each authenticated user is in a **dedicated business operating area**.

A farmer never sees "Orders" and wonders if they should order something.

A buyer knows exactly where to shop.

A retailer sees B2B procurement tools, not farmers' inventory management.

### 4. **Market Composition**

Mambonami itself is **invisible as infrastructure**. Users see:

- Buyers see a marketplace
- Farmers see a storefront
- Retailers see a procurement platform
- Transporters see a job dispatch system

All operating on the **same underlying network**.

### 5. **Momentum**

The flow is designed so that visitors, once engaged, naturally progress through:

Browse → Add to cart → Checkout → Login → Buy → Account → Loyalty

No friction at each step. Just a clear path forward.

---

## Questions & Next Steps

- [ ] Confirm role-specific workspace structure
- [ ] Prioritize which features to build first
- [ ] Define API endpoints for each workspace
- [ ] Design database schema updates (if needed)
- [ ] Plan deployment strategy
- [ ] Set up monitoring and analytics
