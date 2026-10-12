# Mambonami mobile layout guide
  The landing application is designed mobile-first because phones are expected to account for roughly 95% of usage. Tablet and desktop layouts remain enhancements applied with Tailwind's `sm:`, `md:`, `lg:`, and `xl:` breakpoints.
  
  ## Implementation rules
  
  ### 1. Start compact, expand at breakpoints
  Define the phone layout as the unprefixed class and add space only on larger screens.
  
  ```
  <section className="px-4 py-5 sm:px-6 sm:py-8 lg:px-8">
  ```
  Avoid starting with desktop spacing such as `py-12` and trying to override it for phones.
  
  ### 2. Use two-column commerce grids on phones
  Product discovery uses two columns to expose more inventory above the fold:
  
  ```
  <div className="grid grid-cols-2 gap-3 sm:gap-5 lg:grid-cols-3 xl:grid-cols-4">
  ```
  Product cards support this width by using square images, one-line titles, compact price metadata, and a short `Add` label on phones. The full `Add to cart` label returns at `sm`.
  
  ### 3. Keep horizontal choices on one line
  Categories and filter chips should scroll horizontally rather than wrap into several rows:
  
  ```
  <div className="mobile-scroll-row flex gap-2 overflow-x-auto">
  ```
  `mobile-scroll-row` is defined in `src/styles/global.css`. It hides the scrollbar, preserves touch scrolling, and adds edge padding so the first and last options remain reachable.
  
  ### 4. Preserve touch targets while reducing visual space
  Interactive controls remain at least `min-h-10` or `min-h-11`. Density comes from smaller gaps, margins, type hierarchy, and card padding—not from making controls difficult to tap.
  
  ### 5. Respect phone safe areas
  `MainLayout` and `MobileBottomNav` include `env(safe-area-inset-bottom)`. Global scroll padding prevents anchored content from landing behind the fixed bottom navigation.
  
  ### 6. Keep primary actions visible
  On phones:
  
  - Header height is compact, but the menu control remains easy to tap.
  - Bottom navigation stays fixed and role-specific.
  - Hero actions use a two-column row.
  - Product card purchase actions stay at the bottom of equal-height cards.
  - Filter controls use a two-column layout instead of long stacked rows.
  
  ### 7. Reduce promotional section height
  The homepage uses `py-5` or `py-6` on phones and restores roomier spacing at `sm` and above. Supporting cards use two columns where their content remains readable.
  
  ## Reusable mobile patterns
  
  ### Page shell
  
  ```
  <main className="mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-6 lg:px-8 lg:py-8">
  ```
  
  ### Compact content card
  
  ```
  <article className="rounded-xl border border-border bg-card p-3 sm:rounded-2xl sm:p-4">
  ```
  
  ### Responsive heading
  
  ```
  <h1 className="text-2xl font-semibold sm:text-4xl">
  ```
  
  ### Mobile action pair
  
  ```
  <div className="grid grid-cols-2 gap-2 sm:flex sm:flex-wrap sm:gap-3">
  ```
  
  ## Files changed in this pass
  
  - `src/styles/global.css`: safe-area scroll padding and horizontal mobile scroller.
  - `src/shared/layouts/Header.tsx`: shorter phone header and compact branding.
  - `src/shared/layouts/MainLayout.tsx`: bottom-navigation-safe content padding.
  - `src/shared/layouts/MobileBottomNav.tsx`: denser translucent phone navigation.
  - `src/shared/layouts/Footer.tsx`: compact two-column phone footer.
  - `src/shared/components/ui/PageHeader.tsx`: reusable compact mobile page header.
  - `src/features/home/components/*`: shorter hero, denser sections, two-column products, and compact cards.
  - `src/features/home/pages/ProductsPage.tsx`: horizontal category rail and compact filter grid.
  - `src/features/auth/components/AuthLayout.tsx`: reduced empty space around forms.
  - `src/features/buyers/pages/BuyerDashboardPage.tsx`: compact phone dashboard hero.
  
  ## Checklist for future screens
  
  1. Test at 320, 360, 390, and 430 CSS pixels.
  2. Confirm there is no horizontal page overflow.
  3. Keep interactive targets at least 40–44 CSS pixels tall.
  4. Confirm content is not hidden behind the bottom navigation.
  5. Prefer `gap-2`/`gap-3` and `py-4`/`py-5` on phones.
  6. Add larger spacing with responsive prefixes.
  7. Use horizontal rails for chip sets.
  8. Use two-column grids only when labels and controls remain legible.
  9. Check long names, translated copy, loading states, and empty states.
  10. Run the production build after layout changes. make that complete implementation



  What you improved successfully
Your committed implementation now includes:

Two-column mobile product grids
Compact product cards and skeletons
Safe-area-aware fixed navigation
Compact mobile footer
Mobile horizontal category rails
Improved carousel behavior
Mobile admin navigation
Mobile-friendly farmer and transporter metrics
Better table containment
Improved floating-button placement
More compact dashboard components
Recommended next changes
1. Finish compact page shells
Several secondary routes still begin with desktop-like spacing such as py-8, py-10, large pb-8 headers, and p-12 empty states.

Prioritize:

Buyer orders, wishlist, cart, profile, and settings
Retailer dashboard, products, orders, and suppliers
Transport jobs, trips, vehicles, and profile
Public About, Support, How It Works, Cart, Checkout, and Wishlist
Use:

<main className="px-4 py-4 sm:px-6 sm:py-8">
For empty states:

<div className="p-5 sm:p-12">
instead of applying p-12 to phones.

2. Redesign product details around mobile purchasing
ProductDetailPage.tsx still has a large square image followed by considerable spacing before its purchase controls.

Recommended mobile structure:

Compact image carousel
Product name and price
Availability and supplier summary
Sticky bottom purchase bar
Collapsible description and delivery details
Reviews below
Keep “Add to cart” visible above the mobile bottom navigation:

<div className="fixed inset-x-0 bottom-[calc(3.75rem+env(safe-area-inset-bottom))]">
Ensure it does not conflict with role navigation.

3. Optimize cart and checkout for one-handed use
Cart and checkout are high-conversion screens and should receive priority over informational pages.

Recommended changes:

Use compact cart rows rather than large cards.
Keep quantity controls close to the item price.
Add a sticky order total and checkout button.
Collapse optional delivery information.
Avoid requiring users to scroll back to find the main action.
Keep the primary CTA at least 44px tall.
4. Replace mobile tables with record cards
DataTable.tsx still uses a table with min-w-[640px] and horizontal scrolling. This technically works, but is difficult to use on phones.

For admin and operational screens:

<div className="md:hidden">
  {/* Mobile record cards */}
</div>

<div className="hidden md:block">
  {/* Existing data table */}
</div>
Each mobile record should expose:

Primary identifier
Status
Most important value
Timestamp or location
One clear action
Expandable secondary information
Start with disputes, orders, payouts, users, and audit records.

5. Break long registration forms into steps
Registration can become lengthy for farmers, retailers, and transport providers.

Use a short progressive flow:

Account details
Role-specific information
Location or delivery information
Password and confirmation
Review and verify
Also add appropriate mobile keyboards:

<input inputMode="tel" autoComplete="tel" />
<input inputMode="decimal" />
<input inputMode="email" autoComplete="email" />
Persist each step so users do not lose progress after interruptions.

6. Reduce the mobile JavaScript payload
The current production JavaScript bundle is approximately:

1.48 MB minified
339 kB gzip
Route-level lazy loading should be the next technical priority:

const BuyerDashboardPage = lazy(
  () => import("../features/buyers/pages/BuyerDashboardPage")
);
Split at least:

Public marketplace
Authentication
Buyer workspace
Farmer workspace
Retailer workspace
Transport workspace
Admin workspace
Charts and map components
This will have a significant impact for users on slower Kenyan mobile networks.

7. Optimize product imagery
Product images should use:

loading="lazy" below the fold
Explicit width and height or aspect ratio
WebP or AVIF variants
Responsive srcSet
Smaller thumbnails for two-column grids
The hero image should remain eagerly loaded, but secondary homepage and product-grid images should be lazy.

8. Reduce fixed-control congestion
Phones currently may show:

Bottom navigation
Floating action button
Back-to-top button
Sticky actions
Toast notifications
Make these route-aware. For example:

Hide back-to-top on short screens.
Hide floating support controls during checkout.
Place toasts above the bottom navigation.
Display only one floating primary action at a time.
9. Standardize mobile layout primitives
Create reusable classes or components instead of repeatedly tuning individual pages:

PageShell
MobileSection
MobileRecordCard
StickyActionBar
HorizontalChipRail
CompactEmptyState
Suggested defaults:

// Page
"mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8"

// Section spacing
"mt-5 sm:mt-8"

// Card
"rounded-xl border border-border bg-card p-3 sm:rounded-2xl sm:p-5"

// Mobile grid
"grid grid-cols-2 gap-3 sm:gap-5"

// Touch target
"min-h-11"
10. Add a mobile viewport test matrix
Add Playwright projects for:

320 × 568
360 × 800
390 × 844
430 × 932
Test at least:

No horizontal document overflow
Navigation does not cover content
Cart and checkout actions remain reachable
Long product and supplier names do not break cards
Forms remain usable with the software keyboard
Dialogs fit within 100dvh
Loading and empty states do not consume excessive space
Recommended implementation order
Cart and checkout
Product detail purchase flow
Buyer orders and wishlist
Registration and onboarding
Farmer and transporter operational screens
Retailer screens
Admin mobile record cards
Route-level code splitting
Image optimization
Automated mobile viewport testing

## Implementation Status (2026-10-13)

Status reflects the landing application in this workspace. A completed marker means the item is implemented; partial work remains marked incomplete until its stated scope is finished.

1. **Compact page shells**
  - ✅✅ Buyer dashboard, orders, wishlist, cart, profile, and settings use compact phone spacing. Wishlist cards use two columns.
  - ✅✅ Farmer workspace pages, retailer dashboard actions, and transporter dashboards have received mobile spacing improvements.
  - ❌❌ A full compact-shell audit of all retailer, transporter, and public informational routes is still needed.

2. **Product detail purchasing**
  - ✅✅ Product detail has a compact phone image area and an add-to-cart action fixed above the mobile navigation.
  - ❌❌ A real image carousel is blocked by the current product API, which exposes one image URL per product. Collapsible description/delivery sections are not implemented.

3. **Cart and checkout**
  - ✅✅ Cart rows are compact and the phone layout has a sticky subtotal and checkout action.
  - ✅✅ Checkout keeps its validated submit action reachable above the mobile navigation; it returns to normal flow while a form field is focused.
  - ❌❌ Optional delivery details, including the time window, are not collapsed into disclosures.

4. **Mobile admin record cards**
  - ✅✅ Mobile record cards with expandable details and visible actions are implemented for disputes, orders, payouts, users, and audit/security events.
  - ✅✅ Desktop tables remain available from the `md` breakpoint upward.

5. **Progressive registration**
  - ✅✅ Buyer, farmer, retailer, and transport-provider registration use four role-aware steps with per-step validation and a review screen.
  - ✅✅ Non-sensitive fields and step position persist for the browser session. Passwords are excluded and must be re-entered after interruption.

6. **Route-level code splitting**
  - ❌❌ Workspace route chunks and lazy-loaded charts/maps have not been implemented.

7. **Product image optimization**
  - ✅✅ Cart thumbnails load lazily and commerce cards use compact square imagery.
  - ❌❌ Responsive `srcSet`, WebP/AVIF variants, and lazy loading across all below-the-fold product imagery are not implemented.

8. **Fixed-control coordination**
  - ✅✅ Cart and purchase actions are offset above the fixed mobile navigation and reserve scroll space.
  - ❌❌ Floating support, back-to-top, toast, and sticky controls are not yet route-aware as a complete system.

9. **Reusable mobile primitives**
  - ✅✅ Shared horizontal category rails and mobile page/card styling patterns are in use.
  - ❌❌ Dedicated `PageShell`, `MobileRecordCard`, `StickyActionBar`, and compact empty-state components are not implemented.

10. **Viewport test matrix**
  - ❌❌ Automated checks at 320, 360, 390, and 430 CSS pixels have not been added or run.
  - ❌❌ Production build and visual overflow/navigation checks remain unverified because the integrated terminal cannot launch in this environment.