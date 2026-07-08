# MAMBONAMI — Buyer Feature: Complete Flutter Implementation
# we will add without deleting anything done earlier on these document MAMBONAMI — transport, retailer, farmer, common screens, auth already done
> **Copy-paste ready Dart code for `mobile/lib/features/buyer/pages/*` and `mobile/lib/features/buyer/widgets/*`**
> Matches the React App.tsx design. Uses your actual repo patterns: `AppColors`, `CustomCard`, `AppGradients`, `BlocConsumer`, `RoutePaths`, `GetIt`.

---

## File Map

```
lib/features/buyer/
├── pages/
│   ├── buyer_dashboard.dart          ← Home screen (search, banner, categories, products, order strip)
│   ├── product_catalog_page.dart     ← Full catalog with search, filter, sort, grid
│   ├── product_detail_page.dart      ← Product hero, farmer card, qty stepper, add to cart
│   ├── order_confirmation_page.dart --> new not touched in this design
│   ├── dispute_page.dart --> new now touched
│   ├── cart_page.dart                ← Items grouped by farmer, summary, proceed button
│   ├── checkout_page.dart            ← M-Pesa PayBill instructions, countdown, escrow
│   ├── order_history_page.dart       ← Order list with status badges, reorder
│   ├── order_tracking_page.dart      ← Map, driver card, 7-step animated timeline
│   └── dispute_page.dart             ← Dispute form + dispute list tabs
└── widgets/
    ├── product_grid_tile.dart         ← Product card: image, badge, heart, price, add btn, rating
    ├── cart_item.dart                 ← Slidable cart row: image, name, stepper, total, delete
    ├── order_status_timeline.dart     ← 7-step animated timeline with LIVE badge
    ├── otp_verification_dialog.dart   ← Delivery OTP modal: shield, pinput, photo
    ├── farmer_card.dart               ← Farmer info card: avatar, name, location, verified badge
    ├── paybill_instructions_card.dart ← M-Pesa numbered steps + copyable paybill/account
    ├── category_chip_bar.dart         ← Horizontal scrollable category filter chips
    ├── product_search_bar.dart        ← Search input with filter icon button
    ├── delivery_tracking_card.dart    ← Map preview + driver info + ETA stats row
    └── countdown_timer_widget.dart    ← Payment expiry countdown (MM:SS)
```

---

## PAGES

---

### `buyer_dashboard.dart`

```dart
// lib/features/buyer/pages/buyer_dashboard.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/order/order_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../blocs/notification/notification_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/product_grid_tile.dart';
import '../widgets/delivery_tracking_card.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  int _selectedCategory = 0;
  final _categories = ['All', 'Vegetables', 'Fruits', 'Grains', 'Dairy', 'Roots'];

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchProductsEvent());
    context.read<OrderBloc>().add(FetchBuyerOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final String location = 'Westlands, Nairobi';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────
            _buildHeader(context, authState, location),

            // ── Scrollable body ────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<ProductBloc>().add(FetchProductsEvent());
                  context.read<OrderBloc>().add(FetchBuyerOrdersEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero banner
                      _buildHeroBanner(context),
                      const SizedBox(height: 16),

                      // Category chips
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CategoryChipBar(
                          categories: _categories,
                          selected: _selectedCategory,
                          onSelected: (i) => setState(() => _selectedCategory = i),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nearby farmers
                      _buildNearbyFarmers(context),
                      const SizedBox(height: 20),

                      // Recommended products
                      BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          if (state is ProductLoaded) {
                            return _buildProductGrid(context, state);
                          }
                          if (state is ProductLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 20),

                      // Active order tracking strip
                      BlocBuilder<OrderBloc, OrderState>(
                        builder: (context, state) {
                          if (state is BuyerOrdersLoaded && state.activeOrder != null) {
                            return _buildActiveOrderStrip(context, state.activeOrder!);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  // ── Header with location + search ──────────────────────────────
  Widget _buildHeader(BuildContext context, AuthState authState, String location) {
    final notifState = context.watch<NotificationBloc>().state;
    final unread = notifState is NotificationLoaded ? notifState.unreadCount : 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              // Location selector
              Expanded(
                child: GestureDetector(
                  onTap: () {}, // TODO: open address picker
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery to',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            location,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.dark,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16, color: AppColors.muted),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Notification bell
              Stack(
                children: [
                  IconButton(
                    onPressed: () => context.go(RoutePaths.notifications),
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.light,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_none_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              // Avatar
              GestureDetector(
                onTap: () => context.go(RoutePaths.profile),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=40&h=40&fit=crop',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar — taps to catalog
          GestureDetector(
            onTap: () => context.go(RoutePaths.productCatalog),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: AppColors.muted, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Search products, farmers...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero promo banner ─────────────────────────────────────────
  Widget _buildHeroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=160&fit=crop&auto=format',
              height: 148,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Green gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.88),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
            ),
            // Text content
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Flash Deal 🔥',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          )),
                  const SizedBox(height: 4),
                  Text(
                    'Fresh from\nthe Farm',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text('Up to 30% off today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          )),
                ],
              ),
            ),
            // Shop Now button
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => context.go(RoutePaths.productCatalog),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Shop Now',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Nearby farmers horizontal row ────────────────────────────
  Widget _buildNearbyFarmers(BuildContext context) {
    final farmers = [
      {'name': 'Kamau Farm', 'dist': '2.1 km', 'img': 'https://images.unsplash.com/photo-1607305387299-a3d9611cd469?w=60&h=60&fit=crop'},
      {'name': 'Wanjiku Farm', 'dist': '3.4 km', 'img': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=60&h=60&fit=crop'},
      {'name': 'Coastal Farms', 'dist': '5.2 km', 'img': 'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=60&h=60&fit=crop'},
      {'name': 'Thika Growers', 'dist': '7.1 km', 'img': 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=60&h=60&fit=crop'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: 'Nearby Farmers',
            trailing: TextButton(
              onPressed: () => context.go(RoutePaths.productCatalog),
              child: const Text('View all'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: farmers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final f = farmers[i];
              return GestureDetector(
                onTap: () => context.go(RoutePaths.productCatalog),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CachedNetworkImage(
                        imageUrl: f['img']!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      f['name']!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      f['dist']!,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.muted, fontSize: 9),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Recommended products 2-col grid ──────────────────────────
  Widget _buildProductGrid(BuildContext context, ProductLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: 'Recommended for You',
            trailing: TextButton(
              onPressed: () => context.go(RoutePaths.productCatalog),
              child: const Text('See all'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: state.products.length.clamp(0, 6),
          itemBuilder: (context, i) =>
              ProductGridTile(product: state.products[i]),
        ),
      ],
    );
  }

  // ── Active order tracking strip ───────────────────────────────
  Widget _buildActiveOrderStrip(BuildContext context, dynamic order) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Your Active Order'),
          const SizedBox(height: 8),
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.uuid.substring(0, 8).toUpperCase()}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700, color: AppColors.dark),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'On the way',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 5-step progress row
                _buildStepProgress(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.navigation_rounded,
                        size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          const TextSpan(text: 'Driver is '),
                          TextSpan(
                            text: '1.2 km',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark),
                          ),
                          const TextSpan(text: ' away · ETA '),
                          TextSpan(
                            text: '8 min',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () =>
                        context.go(RoutePaths.orderTrackingPath(order.uuid)),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.light,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('View Full Tracking →',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    const steps = ['Placed', 'Confirmed', 'Pickup', 'On way', 'Done'];
    const completed = 4;
    return Row(
      children: List.generate(steps.length, (i) {
        final done = i < completed;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: done ? AppColors.primary : AppColors.light,
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 11, color: Colors.white)
                    : null,
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i < completed - 1
                        ? AppColors.primary
                        : AppColors.light,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
```

---

### `product_catalog_page.dart`

```dart
// lib/features/buyer/pages/product_catalog_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/product_grid_tile.dart';
import '../widgets/product_search_bar.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  final _searchCtrl = TextEditingController();
  int _selectedCategory = 0;
  String _sortBy = 'Latest';

  final _categories = [
    'All', 'Vegetables', 'Fruits', 'Grains', 'Dairy', 'Roots', 'Livestock',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchProductsEvent());
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<ProductBloc>().add(
          SearchProductsEvent(query: _searchCtrl.text.trim()),
        );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SortBottomSheet(
        current: _sortBy,
        onSelected: (v) {
          setState(() => _sortBy = v);
          context.read<ProductBloc>().add(SortProductsEvent(sortBy: v));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search + filter
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.light,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProductSearchBar(
                          controller: _searchCtrl,
                          onFilter: _showSortSheet,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CategoryChipBar(
                    categories: _categories,
                    selected: _selectedCategory,
                    onSelected: (i) {
                      setState(() => _selectedCategory = i);
                      context.read<ProductBloc>().add(
                            FilterProductsByCategoryEvent(
                                category: _categories[i]),
                          );
                    },
                  ),
                ],
              ),
            ),

            // Results count + sort label
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  final count =
                      state is ProductLoaded ? state.products.length : 0;
                  return Row(
                    children: [
                      Text(
                        '$count products found',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _showSortSheet,
                        child: Row(
                          children: [
                            const Icon(Icons.sort_rounded,
                                size: 15, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              _sortBy,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Product grid
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  if (state is ProductError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 48),
                          const SizedBox(height: 12),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<ProductBloc>()
                                .add(FetchProductsEvent()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is ProductLoaded && state.products.isEmpty) {
                    return const EmptyState(
                      emoji: '🥦',
                      title: 'No products found',
                      subtitle:
                          'Try a different search term or category filter.',
                    );
                  }
                  if (state is ProductLoaded) {
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, i) =>
                          ProductGridTile(product: state.products[i]),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortBottomSheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelected;
  const _SortBottomSheet(
      {required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const options = [
      'Latest', 'Price: Low to High', 'Price: High to Low',
      'Nearest Farmer', 'Top Rated',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort by',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ...options.map((opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(opt),
                trailing: current == opt
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary)
                    : null,
                onTap: () {
                  onSelected(opt);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}
```

---

### `product_detail_page.dart`

```dart
// lib/features/buyer/pages/product_detail_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../widgets/farmer_card.dart';

class ProductDetailPage extends StatefulWidget {
  final String? productId;
  final String? productUuid;
  final Product? initialProduct;
  const ProductDetailPage({super.key, this.productId, this.productUuid, this.initialProduct});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  bool _isFavourite = false;
  bool _addingToCart = false;

  Product? get _product {
    final state = context.read<ProductBloc>().state;
    if (widget.initialProduct != null) {
      return widget.initialProduct;
    }
    if (state is ProductLoaded) {
      try {
        final targetId = widget.productId ?? widget.productUuid;
        return state.products.firstWhere((p) {
          final idText = p.id.toString();
          return idText == targetId || p.uuid == targetId;
        });
      } catch (_) {}
    }
    return null;
  }

  Future<void> _addToCart() async {
    final product = _product;
    if (product == null) return;
    setState(() => _addingToCart = true);
    try {
      await GetIt.I<CartRepository>().addProduct(product, _quantity.toDouble());
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Added to cart!');
        context.go(RoutePaths.cart);
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          ),
        ),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final total = (product.pricePerUnit * _quantity).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Hero image app bar ────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _isFavourite = !_isFavourite),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _isFavourite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavourite
                          ? AppColors.error
                          : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.imageUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                  if (product.isOrganic)
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text('Organic',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.dark,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 14,
                                    color: AppColors.gold),
                                const SizedBox(width: 3),
                                Text(
                                  '${product.averageRating}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.dark,
                                      ),
                                ),
                                Text(
                                  '  (${product.reviewCount} reviews)',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'KES ${product.pricePerUnit.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                          ),
                          Text(
                            'per ${product.unit}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Farmer card
                  FarmerCard(
                    farmerName: product.farmerName,
                    farmLocation: product.location ?? 'Kiambu',
                    distanceKm: product.distanceKm ?? 2.1,
                    isVerified: true,
                    imageUrl: null,
                  ),
                  const SizedBox(height: 16),

                  // Quick info chips
                  Row(
                    children: [
                      _InfoChip(
                          label: 'Available',
                          value: '${product.availableQuantity.toStringAsFixed(0)} ${product.unit}'),
                      const SizedBox(width: 10),
                      _InfoChip(
                          label: 'Harvested',
                          value: product.harvestDateLabel ?? '2 days ago'),
                      const SizedBox(width: 10),
                      _InfoChip(
                          label: 'Min Order',
                          value: '1 ${product.unit}'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    product.description ??
                        'Fresh produce sourced directly from certified farmers. No middlemen — fair prices for buyers and farmers alike.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                          height: 1.65,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Quantity selector
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Quantity',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.dark,
                              ),
                        ),
                        const Spacer(),
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                            }
                          },
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$_quantity',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.dark,
                                ),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add_rounded,
                          filled: true,
                          onTap: () {
                            if (_quantity < (product.availableQuantity.toInt())) {
                              setState(() => _quantity++);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Sticky bottom bar ─────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(
                  color: AppColors.light, width: 1)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.muted)),
                Text(
                  'KES $total',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                label: 'Add to Cart 🛒',
                isLoading: _addingToCart,
                onPressed: _addToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _QuantityButton(
      {required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(icon,
              size: 16, color: filled ? Colors.white : AppColors.primary),
        ),
      );
}
```

---

### `cart_page.dart`

```dart
// lib/features/buyer/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../config/route_paths.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../widgets/cart_item.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cartRepo = GetIt.I<CartRepository>();

  @override
  Widget build(BuildContext context) {
    final groups = _cartRepo.itemsGroupedByFarmer;
    final subtotal = _cartRepo.subtotal;
    final deliveryFee = 150.0;
    final platformFee = (subtotal * 0.05).roundToDouble();
    final total = subtotal + deliveryFee + platformFee;

    if (groups.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context, 0),
        body: const EmptyState(
          emoji: '🛒',
          title: 'Your cart is empty',
          subtitle: 'Add fresh produce from nearby farmers to get started.',
          actionLabel: 'Browse Products',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, _cartRepo.totalItems),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Items grouped by farmer
            ...groups.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Farmer header
                      Row(
                        children: [
                          const Icon(Icons.eco_rounded,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            entry.key, // farmer name
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: AppColors.light),
                      ...entry.value.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Slidable(
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) {
                                    _cartRepo.removeItem(item.productId);
                                    setState(() {});
                                  },
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_rounded,
                                  label: 'Remove',
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ],
                            ),
                            child: CartItemWidget(
                              item: item,
                              onQtyChanged: (qty) {
                                _cartRepo.updateQuantity(
                                    item.productId, qty);
                                setState(() {});
                              },
                              onRemove: () {
                                _cartRepo.removeItem(item.productId);
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Order summary
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow('Subtotal',
                      'KES ${subtotal.toStringAsFixed(0)}'),
                  const SizedBox(height: 6),
                  _SummaryRow('Delivery fee',
                      'KES ${deliveryFee.toStringAsFixed(0)}'),
                  const SizedBox(height: 6),
                  _SummaryRow('Platform fee',
                      'KES ${platformFee.toStringAsFixed(0)}'),
                  Divider(
                      height: 20,
                      color: AppColors.light,
                      thickness: 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark,
                              )),
                      Text(
                        'KES ${total.toStringAsFixed(0)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Delivery address
            CustomCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Deliver to',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w700,
                                    color: AppColors.dark)),
                        Text('Westlands, Nairobi',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.muted)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Change',
                        style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Proceed button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        color: Colors.white,
        child: CustomButton(
          label: 'Proceed to Payment — KES ${total.toStringAsFixed(0)}',
          onPressed: () => context.go(RoutePaths.checkout),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, int count) => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.dark),
        ),
        title: Text('My Cart',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                )),
        actions: [
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text('$count items',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12)),
              ),
            ),
        ],
      );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.muted)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                      fontWeight: FontWeight.w600, color: AppColors.dark)),
        ],
      );
}
```

---

### `checkout_page.dart`

```dart
// lib/features/buyer/pages/checkout_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/dtos/order_dto.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../widgets/countdown_timer_widget.dart';
import '../widgets/paybill_instructions_card.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _cartRepo = GetIt.I<CartRepository>();
  final _orderRepo = GetIt.I<OrderRepository>();

  String? _orderId;
  String? _paybillAccount;
  bool _creating = false;
  bool _confirming = false;

  double get _subtotal => _cartRepo.subtotal;
  double get _deliveryFee => 150.0;
  double get _platformFee => (_subtotal * 0.05).roundToDouble();
  double get _total => _subtotal + _deliveryFee + _platformFee;

  @override
  void initState() {
    super.initState();
    _createOrder();
  }

  Future<void> _createOrder() async {
    setState(() => _creating = true);
    try {
      final request = CreateOrderRequest(
        items: _cartRepo.allItems
            .map((item) => CartItemDto(productUuid: item.product.uuid, quantity: item.quantity))
            .toList(),
        deliveryAddress: 'Westlands, Nairobi',
        deliveryStreet: 'Westlands',
        deliveryCity: 'Nairobi',
        deliveryPostalCode: '00100',
        deliveryLat: -1.2672,
        deliveryLng: 36.8107,
        scheduledDate: DateTime.now().toIso8601String(),
        scheduledTimeWindow: 'Today',
      );
      final order = await _orderRepo.createOrder(request);
      final orderUuid = order['uuid']?.toString() ?? '';
      final orderId = order['id']?.toString() ?? orderUuid;
      setState(() {
        _orderId = orderId;
        _paybillAccount = orderUuid.isEmpty ? 'ORD-XXXXXXXX' : 'ORD-${orderUuid.substring(0, 8).toUpperCase()}';
        _creating = false;
      });
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to create order: $e');
        setState(() => _creating = false);
      }
    }
  }

  Future<void> _confirmPayment() async {
    if (_orderId == null) return;
    setState(() => _confirming = true);
    try {
      // Poll for payment confirmation or allow manual confirmation
      context
          .read<OrderBloc>()
          .add(ConfirmPaymentEvent(orderId: _orderId!));
      _cartRepo.clear();
      if (mounted) {
        context.go(RoutePaths.orderTrackingPath(_orderId!));
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, e.toString());
        setState(() => _confirming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Gradient header ────────────────────────────────
            Container(
              decoration: BoxDecoration(gradient: AppGradients.hero),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'M-Pesa Payment',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────
            Expanded(
              child: _creating
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: AppColors.primary),
                          SizedBox(height: 16),
                          Text('Creating your order...',
                              style: TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      child: Column(
                        children: [
                          // M-Pesa instructions
                          PaybillInstructionsCard(
                            paybillNumber: '123456',
                            accountNumber: _paybillAccount ?? 'ORD-XXXXXXXX',
                            amount: _total,
                          ),
                          const SizedBox(height: 16),

                          // Payment expiry countdown
                          if (_orderId != null)
                            CustomCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_outlined,
                                      color: AppColors.gold, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Payment expires in',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.dark),
                                  ),
                                  const Spacer(),
                                  CountdownTimerWidget(
                                    durationSeconds: 14 * 60,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.gold,
                                        ),
                                    onExpired: () =>
                                        CustomSnackbar.showError(
                                            context,
                                            'Payment window expired. Please try again.'),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Summary card
                          CustomCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Payment Summary',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.dark,
                                        )),
                                const SizedBox(height: 12),
                                _Row('Subtotal',
                                    'KES ${_subtotal.toStringAsFixed(0)}'),
                                const SizedBox(height: 5),
                                _Row('Delivery fee',
                                    'KES ${_deliveryFee.toStringAsFixed(0)}'),
                                const SizedBox(height: 5),
                                _Row('Platform fee',
                                    'KES ${_platformFee.toStringAsFixed(0)}'),
                                Divider(
                                    height: 20, color: AppColors.light),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.dark,
                                            )),
                                    Text(
                                      'KES ${_total.toStringAsFixed(0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Escrow info banner
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.18)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.shield_rounded,
                                    color: AppColors.primary, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Your payment is held in escrow by MAMBONAMI until delivery is confirmed. You can raise a dispute within 48 hours.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.muted),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // ── Confirm button ─────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              color: Colors.white,
              child: CustomButton(
                label: 'I Have Paid — Confirm',
                isLoading: _confirming,
                onPressed: _orderId != null ? _confirmPayment : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.muted)),
          Text(value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.dark)),
        ],
      );
}
```

---

### `order_tracking_page.dart`

```dart
// lib/features/buyer/pages/order_tracking_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/custom_card.dart';
import '../widgets/delivery_tracking_card.dart';
import '../widgets/order_status_timeline.dart';

class OrderTrackingPage extends StatefulWidget {
  final String? orderId;
  final String? orderUuid;
  const OrderTrackingPage({super.key, this.orderId, this.orderUuid});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  @override
  void initState() {
    super.initState();
    final orderId = widget.orderId ?? widget.orderUuid;
    if (orderId != null) {
      context
          .read<OrderBloc>()
          .add(FetchOrderDetailsEvent(orderId: orderId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Gradient header ────────────────────────────────
            Container(
              decoration: BoxDecoration(gradient: AppGradients.hero),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Order Tracking',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        final label = state is OrderDetailLoaded
                            ? state.order.statusLabel
                            : '—';
                        final orderId = widget.orderId ?? widget.orderUuid ?? 'unknown';
                        return Text(
                          'Order #${orderId.substring(0, 8).toUpperCase()} · $label',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ────────────────────────────────
            Expanded(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  if (state is OrderError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 48),
                          const SizedBox(height: 12),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<OrderBloc>().add(
                                FetchOrderDetailsEvent(
                                    orderId: widget.orderId ?? widget.orderUuid ?? '')),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => context
                        .read<OrderBloc>()
                        .add(FetchOrderDetailsEvent(
                            orderId: widget.orderId ?? widget.orderUuid ?? '')),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: Column(
                        children: [
                          // Map + driver card
                          DeliveryTrackingCard(
                            driverName: 'David Ochieng',
                            vehicleLabel: 'Motorcycle · KAB 123A',
                            distanceKm: 1.2,
                            etaMinutes: 8,
                            rating: 4.8,
                            driverImageUrl:
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=40&h=40&fit=crop',
                            mapImageUrl:
                                'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=380&h=140&fit=crop',
                            onCallDriver: () {},
                          ),
                          const SizedBox(height: 16),

                          // 7-step timeline
                          CustomCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Timeline',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.dark,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                OrderStatusTimeline(
                                  events: [
                                    OrderStatusEvent(
                                      title: 'Order Placed',
                                      description:
                                          'Order received and recorded',
                                      timestamp: '10:32 AM',
                                      isCompleted: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'Payment Received',
                                      description:
                                          'Funds secured in escrow',
                                      timestamp: '10:33 AM',
                                      isCompleted: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'Farmer Accepted',
                                      description:
                                          'John Kamau confirmed your order',
                                      timestamp: '10:45 AM',
                                      isCompleted: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'Order Ready',
                                      description:
                                          'Produce packed for pickup',
                                      timestamp: '11:20 AM',
                                      isCompleted: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'Transport Assigned',
                                      description: 'David O. accepted trip',
                                      timestamp: '11:35 AM',
                                      isCompleted: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'On the Way',
                                      description:
                                          '1.2 km away · ETA 8 minutes',
                                      timestamp: '11:52 AM',
                                      isCompleted: true,
                                      isActive: true,
                                    ),
                                    OrderStatusEvent(
                                      title: 'Delivered',
                                      description:
                                          'Awaiting delivery confirmation',
                                      timestamp: '—',
                                      isCompleted: false,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### `order_history_page.dart`

```dart
// lib/features/buyer/pages/order_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/empty_state.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(FetchBuyerOrdersEvent());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'paid_escrow':
      case 'transport_assigned':
      case 'picked_up':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'paid_escrow':
        return 'Paid';
      case 'transport_assigned':
        return 'Assigned';
      case 'picked_up':
        return 'Picked Up';
      default:
        return 'Processing';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.dark),
        ),
        title: Text(
          'Order History',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
        ),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is BuyerOrdersLoaded && state.orders.isEmpty) {
            return const EmptyState(
              emoji: '📦',
              title: 'No orders yet',
              subtitle:
                  'Your order history will appear here after your first purchase.',
            );
          }
          if (state is BuyerOrdersLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async =>
                  context.read<OrderBloc>().add(FetchBuyerOrdersEvent()),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final o = state.orders[i];
                  final color = _statusColor(o.status);
                  return GestureDetector(
                    onTap: () =>
                        context.go(RoutePaths.orderTrackingPath(o.uuid)),
                    child: CustomCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ORD-${o.uuid.substring(0, 8).toUpperCase()}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.dark,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    o.createdAtLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: AppColors.muted),
                                  ),
                                ],
                              ),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(99),
                                ),
                                child: Text(
                                  _statusLabel(o.status),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            o.itemsSummary,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.muted),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'KES ${o.total.toStringAsFixed(0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                              ),
                              if (o.status == 'delivered')
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                        color: AppColors.primary),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 4),
                                  ),
                                  child: const Text('Reorder',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

### `pages/dispute_page.dart`

```dart
// mobile/lib/features/buyer/pages/dispute_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../blocs/dispute/dispute_bloc.dart';
import '../../../data/dtos/dispute_dto.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_image_picker.dart';
import '../../../shared/widgets/custom_snackbar.dart';

class DisputePage extends StatefulWidget {
  const DisputePage({super.key});

  @override
  State<DisputePage> createState() => _DisputePageState();
}

class _DisputePageState extends State<DisputePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _orderUuidController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<File> _evidenceImages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<DisputeBloc>().add(const FetchMyDisputesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderUuidController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await CustomImagePicker.pickMultipleImages(maxCount: 5 - _evidenceImages.length);
    if (picked.isNotEmpty) {
      setState(() {
        _evidenceImages.addAll(picked);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _evidenceImages.removeAt(index);
    });
  }

  Future<void> _submitDispute() async {
    if (!_formKey.currentState!.validate()) return;
    if (_evidenceImages.isEmpty) {
      CustomSnackbar.showWarning(context, 'Please add at least one evidence photo.');
      return;
    }

    final request = CreateDisputeRequest(
      orderUuid: _orderUuidController.text.trim(),
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;
    context.read<DisputeBloc>().add(CreateDisputeEvent(request));
  }

  void _onDisputeCreated(BuildContext context) {
    _orderUuidController.clear();
    _subjectController.clear();
    _descriptionController.clear();
    setState(() => _evidenceImages.clear());
    _tabController.animateTo(0);
    CustomSnackbar.showSuccess(context, 'Dispute submitted successfully.');
    context.read<DisputeBloc>().add(const FetchMyDisputesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Disputes',
        showNotificationAction: true,
        showBackButton: true,
        actions: const [CartActionButton()],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(text: 'My Disputes'),
              Tab(text: 'New Dispute'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDisputesListTab(context),
                _buildNewDisputeTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputesListTab(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<DisputeBloc, DisputeState>(
      listener: (context, state) {
        if (state is DisputeError) {
          CustomSnackbar.showError(context, 'Error: ${state.message}');
        }
      },
      child: BlocBuilder<DisputeBloc, DisputeState>(
        builder: (context, state) {
          if (state is DisputeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyDisputesLoaded) {
            if (state.disputes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 48, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'No disputes yet',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a new dispute if you need help with an order',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.disputes.length,
              itemBuilder: (context, index) {
                final dispute = state.disputes[index];
                return CustomCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                dispute.subject,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _buildStatusBadge(dispute.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dispute.description,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order: ${dispute.orderUuid.substring(0, 8)}...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(dispute.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is DisputeError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const Center(child: Text('No disputes found'));
        },
      ),
    );
  }

  Widget _buildNewDisputeTab(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<DisputeBloc, DisputeState>(
      listener: (context, state) {
        if (state is DisputeCreated) {
          _onDisputeCreated(context);
        } else if (state is DisputeError) {
          CustomSnackbar.showError(context, 'Error: ${state.message}');
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Need help with an order?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share the issue below and our team will respond shortly.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _orderUuidController,
                    decoration: const InputDecoration(
                      labelText: 'Order UUID',
                      hintText: 'Enter the order ID',
                    ),
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Enter order UUID' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      hintText: 'e.g., Item quality issue',
                    ),
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Enter a subject' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe the issue in detail...',
                    ),
                    maxLines: 6,
                    validator: (value) =>
                        value?.trim().isEmpty == true ? 'Enter a description' : null,
                  ),
                  const SizedBox(height: 20),
                  // Evidence photos section
                  _buildEvidenceSection(context),
                  const SizedBox(height: 20),
                  BlocBuilder<DisputeBloc, DisputeState>(
                    builder: (context, state) {
                      final isLoading = state is DisputeLoading;
                      return CustomButton(
                        label: 'Submit Dispute',
                        onPressed: isLoading ? null : _submitDispute,
                        isLoading: isLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence Photos (max 5)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (_evidenceImages.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _evidenceImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _evidenceImages[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        if (_evidenceImages.length < 5)
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text('Add Photo (${_evidenceImages.length}/5)'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.outline),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'open':
        backgroundColor = AppColors.warning;
        break;
      case 'resolved':
        backgroundColor = AppColors.success;
        break;
      case 'closed':
        backgroundColor = AppColors.muted;
        break;
      default:
        backgroundColor = AppColors.muted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
```


### `order_confirmation_page.dart`

```dart
// mobile/lib/features/buyer/pages/order_confirmation_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';

class OrderConfirmationPage extends StatefulWidget {
  final String orderUuid;
  const OrderConfirmationPage({super.key, required this.orderUuid});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order Confirmed',
        showBackButton: true,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── Animated Checkmark ────────────────────────────────────
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    gradient: AppGradients.hero,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.40),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 58,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Gold Divider ───────────────────────────────────────────
              Container(
                width: 64,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Title ──────────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Order Confirmed! 🎉',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ─── Subtitle ──────────────────────────────────────────────
              Text(
                'Your order has been placed successfully.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 8),

              // ─── Order Number ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Order #${widget.orderUuid.substring(0, 8).toUpperCase()}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Info Text ─────────────────────────────────────────────
              Text(
                'You can track the delivery and view order status in the Orders section.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // ─── Track Order Button ────────────────────────────────────
              CustomButton(
                label: 'Track Order',
                onPressed: () => context.go(RoutePaths.orderTrackingPath(widget.orderUuid)),
                icon: const Icon(Icons.route_outlined),
              ),
              const SizedBox(height: 12),

              // ─── Back to Home ──────────────────────────────────────────
              OutlinedButton(
                onPressed: () => context.go(RoutePaths.buyerDashboard),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## WIDGETS

---

### `product_grid_tile.dart`

```dart
// lib/features/buyer/widgets/product_grid_tile.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../shared/themes/app_colors.dart';

class ProductGridTile extends StatefulWidget {
  final Product product;
  const ProductGridTile({super.key, required this.product});

  @override
  State<ProductGridTile> createState() => _ProductGridTileState();
}

class _ProductGridTileState extends State<ProductGridTile> {
  bool _isFavourite = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return GestureDetector(
      onTap: () => context.go(RoutePaths.productDetailPath(p.uuid)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: p.imageUrl ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          color: AppColors.light,
                          child: const Icon(Icons.image_outlined,
                              color: AppColors.muted)),
                      errorWidget: (_, __, ___) => Container(
                          color: AppColors.light,
                          child: const Icon(Icons.broken_image_outlined,
                              color: AppColors.muted)),
                    ),
                  ),
                  // Badge
                  if (p.badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          p.badge!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  // Heart
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _isFavourite = !_isFavourite),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6),
                          ],
                        ),
                        child: Icon(
                          _isFavourite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 15,
                          color: _isFavourite
                              ? AppColors.error
                              : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.farmerName ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KES ${p.pricePerUnit.toStringAsFixed(0)}/${p.unit}',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await GetIt.I<CartRepository>().addProduct(p, 1);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text('Added to cart'),
                                backgroundColor: AppColors.primary,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 11, color: AppColors.gold),
                      const SizedBox(width: 2),
                      Text(
                        '${p.averageRating}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### `cart_item.dart`

```dart
// lib/features/buyer/widgets/cart_item.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/models/cart_item.dart';
import '../../../shared/themes/app_colors.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final ValueChanged<double> onQtyChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQtyChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final lineTotal =
        (item.pricePerUnit * item.quantity).toStringAsFixed(0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: item.imageUrl ?? '',
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(color: AppColors.light),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.light,
              child: const Icon(Icons.image_not_supported_outlined,
                  color: AppColors.muted),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Name + price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'KES ${item.pricePerUnit.toStringAsFixed(0)} / ${item.unit}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 6),
              // Quantity stepper
              Row(
                children: [
                  _QtyButton(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      if (item.quantity > 1) {
                        onQtyChanged(item.quantity - 1);
                      } else {
                        onRemove();
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${item.quantity}',
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark,
                              ),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add_rounded,
                    filled: true,
                    onTap: () {
                      if (item.quantity < item.maxQty) {
                        onQtyChanged(item.quantity + 1);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Line total + delete
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'KES $lineTotal',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _QtyButton(
      {required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: filled
                ? null
                : Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Icon(icon,
              size: 14,
              color: filled ? Colors.white : AppColors.primary),
        ),
      );
}
```

---

### `order_status_timeline.dart`

```dart
// lib/features/buyer/widgets/order_status_timeline.dart

import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';

class OrderStatusEvent {
  final String title;
  final String? description;
  final String? timestamp;
  final bool isCompleted;
  final bool isActive;

  const OrderStatusEvent({
    required this.title,
    this.description,
    this.timestamp,
    required this.isCompleted,
    this.isActive = false,
  });
}

class OrderStatusTimeline extends StatelessWidget {
  final List<OrderStatusEvent> events;
  const OrderStatusTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(events.length, (i) {
        final e = events[i];
        final isLast = i == events.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: dot + line
            Column(
              children: [
                _Dot(
                  isCompleted: e.isCompleted,
                  isActive: e.isActive,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 44,
                    color: e.isCompleted
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.light,
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Right column: title + desc + time
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          e.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: e.isCompleted
                                    ? AppColors.dark
                                    : AppColors.muted,
                              ),
                        ),
                        if (e.isActive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.gold.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (e.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        e.description!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                    if (e.timestamp != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        e.timestamp!,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;
  const _Dot({required this.isCompleted, required this.isActive});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isCompleted
              ? (isActive ? AppColors.gold : AppColors.primary)
              : AppColors.light,
          shape: BoxShape.circle,
        ),
        child: isCompleted
            ? const Icon(Icons.check_rounded,
                size: 14, color: Colors.white)
            : Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.muted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
      );
}
```

---

### `otp_verification_dialog.dart`

```dart
// lib/features/buyer/widgets/otp_verification_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../blocs/trip/trip_bloc.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

/// Show this dialog at delivery: buyer reads code → driver enters here.
class OtpVerificationDialog extends StatefulWidget {
  final String orderId;
  final VoidCallback onSuccess;

  const OtpVerificationDialog({
    super.key,
    required this.orderId,
    required this.onSuccess,
  });

  @override
  State<OtpVerificationDialog> createState() =>
      _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  String _otp = '';
  bool _loading = false;
  String? _error;
  int _attemptsLeft = 3;

  final _defaultTheme = PinTheme(
    width: 58,
    height: 58,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
    ),
    textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary),
  );

  final _focusedTheme = PinTheme(
    width: 58,
    height: 58,
    decoration: BoxDecoration(
      color: AppColors.surfaceHighLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary, width: 2),
    ),
    textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary),
  );

  Future<void> _verify() async {
    if (_otp.length < 4) {
      setState(() => _error = 'Enter the 4-digit code');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      context.read<TripBloc>().add(
            VerifyDeliveryOtpEvent(
              orderId: widget.orderId,
              otp: _otp,
            ),
          );
      Navigator.of(context).pop();
      widget.onSuccess();
    } catch (e) {
      setState(() {
        _attemptsLeft--;
        _error = _attemptsLeft > 0
            ? 'Wrong code — $_attemptsLeft attempt${_attemptsLeft == 1 ? "" : "s"} left'
            : 'No more attempts. Contact support.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shield icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.shield_rounded,
                  color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),

            Text(
              'Enter Delivery OTP',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ask the buyer for the 4-digit code shown in their app.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 20),

            // Pinput OTP
            Pinput(
              length: 4,
              keyboardType: TextInputType.number,
              defaultPinTheme: _defaultTheme,
              focusedPinTheme: _focusedTheme,
              submittedPinTheme: _focusedTheme,
              onChanged: (v) => setState(() => _otp = v),
              onCompleted: (v) { _otp = v; _verify(); },
            ),

            // Error message
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],

            const SizedBox(height: 20),

            // Expiry note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.gold, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'OTP expires in 5 minutes. Escrow released after confirmation.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _loading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.muted,
                      side: BorderSide(
                          color:
                              AppColors.muted.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: 'Verify OTP',
                    isLoading: _loading,
                    onPressed: _attemptsLeft > 0 ? _verify : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### `farmer_card.dart`

```dart
// lib/features/buyer/widgets/farmer_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';

class FarmerCard extends StatelessWidget {
  final String farmerName;
  final String farmLocation;
  final double distanceKm;
  final bool isVerified;
  final String? imageUrl;
  final VoidCallback? onTap;

  const FarmerCard({
    super.key,
    required this.farmerName,
    required this.farmLocation,
    required this.distanceKm,
    this.isVerified = false,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // Farmer avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: AppColors.primary.withValues(alpha: 0.15),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.primary, size: 24),
                    ),
            ),
            const SizedBox(width: 12),

            // Name + location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmerName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: AppColors.muted),
                      const SizedBox(width: 2),
                      Text(
                        '$farmLocation · ${distanceKm.toStringAsFixed(1)} km',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Verified badge
            if (isVerified)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  '✓ Verified',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

### `paybill_instructions_card.dart`

```dart
// lib/features/buyer/widgets/paybill_instructions_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';

class PaybillInstructionsCard extends StatefulWidget {
  final String paybillNumber;
  final String accountNumber;
  final double amount;

  const PaybillInstructionsCard({
    super.key,
    required this.paybillNumber,
    required this.accountNumber,
    required this.amount,
  });

  @override
  State<PaybillInstructionsCard> createState() =>
      _PaybillInstructionsCardState();
}

class _PaybillInstructionsCardState
    extends State<PaybillInstructionsCard> {
  bool _paybillCopied = false;
  bool _accountCopied = false;

  Future<void> _copy(String text, bool isPaybill) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() {
      if (isPaybill) {
        _paybillCopied = true;
      } else {
        _accountCopied = true;
      }
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _paybillCopied = false;
        _accountCopied = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Open your M-Pesa app or dial *334#',
      'Select Lipa na M-Pesa → Pay Bill',
      'Enter Business Number: ${widget.paybillNumber}',
      'Enter Account Number: ${widget.accountNumber}',
      'Enter Amount: KES ${widget.amount.toStringAsFixed(0)}',
      'Enter your M-Pesa PIN and confirm',
    ];

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shield_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pay via M-Pesa',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                          )),
                  Text('Funds held securely in escrow',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.muted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Numbered steps
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FOLLOW THESE STEPS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.muted,
                      ),
                ),
                const SizedBox(height: 12),
                ...steps.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.dark),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Copyable paybill + account numbers
          Row(
            children: [
              Expanded(
                child: _CopyCard(
                  label: 'Paybill Number',
                  value: widget.paybillNumber,
                  copied: _paybillCopied,
                  onCopy: () => _copy(widget.paybillNumber, true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CopyCard(
                  label: 'Account Number',
                  value: widget.accountNumber,
                  copied: _accountCopied,
                  onCopy: () => _copy(widget.accountNumber, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CopyCard extends StatelessWidget {
  final String label;
  final String value;
  final bool copied;
  final VoidCallback onCopy;

  const _CopyCard({
    required this.label,
    required this.value,
    required this.copied,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onCopy,
                  child: Icon(
                    copied
                        ? Icons.check_circle_rounded
                        : Icons.copy_rounded,
                    size: 16,
                    color: copied ? AppColors.success : AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
```

---

### `category_chip_bar.dart`

```dart
// lib/features/buyer/widgets/category_chip_bar.dart

import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';

class CategoryChipBar extends StatelessWidget {
  final List<String> categories;
  final int selected;
  final ValueChanged<int> onSelected;

  const CategoryChipBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isActive = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.light,
                borderRadius: BorderRadius.circular(99),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

### `product_search_bar.dart`

```dart
// lib/features/buyer/widgets/product_search_bar.dart

import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onFilter;
  final String hint;

  const ProductSearchBar({
    super.key,
    required this.controller,
    this.onFilter,
    this.hint = 'Search products, farmers...',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.dark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.muted),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.muted, size: 18),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                    color: AppColors.secondary, width: 1.5),
              ),
            ),
          ),
        ),
        if (onFilter != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onFilter,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ],
    );
  }
}
```

---

### `delivery_tracking_card.dart`

```dart
// lib/features/buyer/widgets/delivery_tracking_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';

class DeliveryTrackingCard extends StatelessWidget {
  final String driverName;
  final String vehicleLabel;
  final double distanceKm;
  final int etaMinutes;
  final double rating;
  final String? driverImageUrl;
  final String? mapImageUrl;
  final VoidCallback? onCallDriver;

  const DeliveryTrackingCard({
    super.key,
    required this.driverName,
    required this.vehicleLabel,
    required this.distanceKm,
    required this.etaMinutes,
    required this.rating,
    this.driverImageUrl,
    this.mapImageUrl,
    this.onCallDriver,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Map preview
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: mapImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: mapImageUrl!,
                    height: 144,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 144,
                    color: AppColors.light,
                    child: const Center(
                      child: Icon(Icons.map_rounded,
                          color: AppColors.muted, size: 48),
                    ),
                  ),
          ),

          // Driver info row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: driverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: driverImageUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 44,
                          height: 44,
                          color: AppColors.light,
                          child: const Icon(Icons.person_rounded,
                              color: AppColors.muted),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.local_shipping_rounded,
                              size: 12, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            vehicleLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onCallDriver != null)
                  GestureDetector(
                    onTap: onCallDriver,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.light,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.phone_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                  ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                _Stat(value: '${distanceKm.toStringAsFixed(1)} km',
                    label: 'Distance'),
                const SizedBox(width: 10),
                _Stat(value: '$etaMinutes min', label: 'ETA'),
                const SizedBox(width: 10),
                _Stat(
                    value: '★ ${rating.toStringAsFixed(1)}',
                    label: 'Rating'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
```

---

### `countdown_timer_widget.dart`

```dart
// lib/features/buyer/widgets/countdown_timer_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';

/// Displays a live MM:SS countdown.
/// Call [onExpired] when it reaches zero.
class CountdownTimerWidget extends StatefulWidget {
  final int durationSeconds;
  final TextStyle? style;
  final VoidCallback? onExpired;

  const CountdownTimerWidget({
    super.key,
    required this.durationSeconds,
    this.style,
    this.onExpired,
  });

  @override
  State<CountdownTimerWidget> createState() =>
      _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 0) {
        _timer?.cancel();
        widget.onExpired?.call();
        return;
      }
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _label {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) =>
      Text(_label, style: widget.style);
}
```

---

## Route Paths to add in `lib/config/route_paths.dart`

```dart
// mobile/lib/config/route_paths.dart

class RoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const welcome = '/welcome';
  static const otp = '/otp';
  static const roleSelect = '/role-select';
  static const success = '/success';
  static const register = '/register';
  static const registerFarmer = '/register/farmer';
  static const registerBuyer = '/register/buyer';
  static const registerTransport = '/register/transport';
  static const registerRetailer = '/register/retailer';
  static const forgotPassword = '/forgot-password';

  static const buyerDashboard = '/buyer';
  static const productCatalog = '/buyer/catalog';
  static const orderHistory = '/buyer/orders';
  static const farmerDashboard = '/farmer';
  static const transportProviderDashboard = '/transport_provider';
  static const availableOrders = '/transport_provider/available-orders';
  static const myTrips = '/transport_provider/my-trips';
  static const tripDetail = '/transport_provider/trip/:uuid';
  static String tripDetailPath(String uuid) => '/transport_provider/trip/$uuid';
  static const pickup = '/transport_provider/pickup/:uuid';
  static String pickupPath(String uuid) => '/transport_provider/pickup/$uuid';
  static const delivery = '/transport_provider/delivery/:uuid';
  static String deliveryPath(String uuid) => '/transport_provider/delivery/$uuid';
  static const transportEarnings = '/transport_provider/earnings';

  static const farmerProducts = '/farmer/products';
  static const farmerProductCreate = '/farmer/products/create';
  static const farmerProductEdit = '/farmer/products/:uuid/edit';
  static String farmerProductEditPath(String uuid) => '/farmer/products/$uuid/edit';

  static const farmerOrderRequests = '/farmer/order-requests';
  static const farmerOrderRequestDetail = '/farmer/order-requests/:id';
  static String farmerOrderRequestDetailPath(int id) => '/farmer/order-requests/$id';

  static const farmerEarnings = '/farmer/earnings';

  static const notifications = '/notifications';
  static const orders = '/orders';
  static const products = '/products';
  static const productDetail = '/product/:uuid';
  static String productDetailPath(String uuid) => '/product/$uuid';
  static const cart = '/cart';
  static const addressPicker = '/address-picker';
  static const checkout = '/checkout';
  static const orderConfirmation = '/checkout/confirmation/:uuid';
  static const dispute = '/dispute';
  static const profile = '/profile';
  static const settings = '/settings';
  static const support = '/support';
  static const orderTracking = '/order/:uuid';
  static String orderTrackingPath(String uuid) => '/order/$uuid';
  static String orderConfirmationPath(String uuid) => '/checkout/confirmation/$uuid';
}
```

## `role_routes.dart`

```dart
// lib/config/role_routes.dart

import 'route_paths.dart';

enum UserRole {
  buyer,
  retailer,
  farmer,
  transport,
  admin,
}

class AppRole {
  static const buyer = 'buyer';
  static const retailer = 'retailer';
  static const farmer = 'farmer';
  static const transportProvider = 'transport_provider';
  static const admin = 'admin';

  static const buyerRoles = [buyer, retailer];
  static const farmerRoles = [farmer];
  static const transportProviderRoles = [transportProvider];
  static const operationalRoles = [buyer, retailer, farmer, transportProvider];
  static const allRoles = [buyer, retailer, farmer, transportProvider, admin];

  static String homePathFor(String? role) {
    switch (role) {
      case buyer:
      case retailer:
        return RoutePaths.buyerDashboard;
      case farmer:
        return RoutePaths.farmerDashboard;
      case transportProvider:
        return RoutePaths.transportProviderDashboard;
      case admin:
        return '/admin';
      default:
        return RoutePaths.login;
    }
  }

  static UserRole parseUserRole(String? role) {
    switch (role) {
      case buyer:
        return UserRole.buyer;
      case retailer:
        return UserRole.retailer;
      case farmer:
        return UserRole.farmer;
      case transportProvider:
        return UserRole.transport;
      case admin:
        return UserRole.admin;
      default:
        return UserRole.buyer;
    }
  }

  static bool isHomePathForRole(String path, String role) {
    final homePath = homePathFor(role);
    return homePath != RoutePaths.login &&
        (path == homePath || path.startsWith('$homePath/'));
  }

  static String registrationPathFor(String? role) {
    switch (role) {
      case farmer:
        return RoutePaths.registerFarmer;
      case buyer:
      case retailer:
        return role == retailer ? RoutePaths.registerRetailer : RoutePaths.registerBuyer;
      case transportProvider:
        return RoutePaths.registerTransport;
      default:
        return RoutePaths.register;
    }
  }

  static String displayLabel(String? role) {
    switch (role) {
      case buyer:
        return 'Buyer';
      case retailer:
        return 'Retailer';
      case farmer:
        return 'Farmer';
      case transportProvider:
        return 'Transport Provider';
      case admin:
        return 'Admin';
      default:
        return 'Guest';
    }
  }
}
```

## `role_routes.dart`

```dart
// mobile/lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/auth_guard.dart';
import '../core/deep_link_handler.dart';
import 'route_paths.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/splash_page.dart';
import '../features/auth/pages/welcome_page.dart';
import '../features/auth/pages/otp_page.dart';
import '../features/auth/pages/role_select_page.dart';
import '../features/auth/pages/success_page.dart';
import '../features/auth/pages/buyer_register.dart';
import '../features/auth/pages/farmer_register_page.dart';
import '../features/auth/pages/retailer_register_page.dart';
import '../features/auth/pages/transport_register_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/buyer/pages/buyer_dashboard.dart';
import '../features/farmer/pages/farmer_dashboard.dart';
import '../features/transport/pages/provider_dashboard.dart';
import '../features/transport/pages/available_orders_page.dart';
import '../features/transport/pages/my_trips_page.dart';
import '../features/transport/pages/trip_detail_page.dart';
import '../features/transport/pages/pickup_page.dart';
import '../features/transport/pages/delivery_page.dart';
import '../features/transport/pages/earnings_page.dart';
import '../features/notifications/pages/notifications_page.dart';
import '../features/buyer/pages/order_tracking_page.dart';
import '../features/buyer/pages/order_history_page.dart';
import '../features/buyer/pages/product_catalog_page.dart';
import '../features/buyer/pages/product_detail_page.dart';
import '../features/buyer/pages/cart_page.dart';
import '../features/buyer/pages/checkout_page.dart';
import '../features/buyer/pages/address_picker_page.dart';
import '../features/buyer/pages/order_confirmation_page.dart';
import '../features/buyer/pages/dispute_page.dart';
import '../data/models/product.dart';
import '../data/models/order.dart';
import '../features/farmer/pages/product_list_page.dart';
import '../features/farmer/pages/product_create_page.dart';
import '../features/farmer/pages/product_edit_page.dart';
import '../features/farmer/pages/order_requests_page.dart';
import '../features/farmer/pages/order_detail_page.dart';
import '../features/farmer/pages/earnings_page.dart';
import '../features/common/profile_page.dart';
import '../features/common/settings_page.dart' as settings_page;
import '../features/common/support_page.dart' as support_page;
import '../blocs/auth/auth_bloc.dart';
import 'role_routes.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off_rounded, size: 64),
              const SizedBox(height: 12),
              Text(
                'We could not find that page.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please return to the home screen and try again.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go(AppRole.homePathFor(context.read<AuthBloc>().state is AuthAuthenticated ? (context.read<AuthBloc>().state as AuthAuthenticated).role : null)),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) => _handleDeepLinksAndAuth(context, state),
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (_, __) => const SplashPage()),
      GoRoute(path: RoutePaths.welcome, builder: (_, __) => const WelcomePage()),
      GoRoute(path: RoutePaths.login, builder: (_, __) => const LoginPage()),
      GoRoute(
        path: RoutePaths.otp,
        builder: (context, state) {
          final extra = state.extra;
          String? phone;
          String? mode;
          Map<String, dynamic>? data;

          if (extra is Map<String, dynamic>) {
            phone = extra['phone']?.toString();
            mode = extra['mode']?.toString();
            data = extra;
          } else if (extra is String) {
            phone = extra;
          }

          return OtpPage(phone: phone ?? 'your phone', mode: mode, data: data);
        },
      ),
      GoRoute(path: RoutePaths.roleSelect, builder: (_, __) => const RoleSelectPage()),
      GoRoute(
        path: RoutePaths.success,
        builder: (context, state) {
          final extra = state.extra;
          final role = extra is Map<String, dynamic>
              ? extra['role'] as String?
              : null;
          return SuccessPage(role: role);
        },
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (_, __) => const RoleSelectPage(),
      ),
      GoRoute(
        path: RoutePaths.registerFarmer,
        builder: (_, __) => const FarmerRegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.registerBuyer,
        builder: (_, __) => const BuyerRegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.registerTransport,
        builder: (_, __) => const TransportRegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.registerRetailer,
        builder: (_, __) => const RetailerRegisterPage(),
      ),
      GoRoute(
          path: RoutePaths.forgotPassword,
          builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(
        path: RoutePaths.buyerDashboard,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: BuyerDashboard(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerDashboard,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.farmerRoles,
          child: FarmerDashboard(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerProducts,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.farmerRoles,
          child: ProductListPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerProductCreate,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.farmerRoles,
          child: ProductCreatePage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerProductEdit,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          final extra = state.extra;
          Product? product;
          if (extra is Product) product = extra;
          if (uuid == null)
            return const Scaffold(
                body: Center(child: Text('Missing product id')));
          return AuthGuard(
            allowedRoles: AppRole.farmerRoles,
            child: ProductEditPage(productUuid: uuid, initialProduct: product),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.farmerOrderRequests,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.farmerRoles,
          child: OrderRequestsPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerEarnings,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.farmerRoles,
          child: EarningsPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.farmerOrderRequestDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final extra = state.extra;
          SubOrder? subOrder;
          if (extra is SubOrder) subOrder = extra;
          if (id == null) {
            return const Scaffold(
                body: Center(child: Text('Missing order request id')));
          }
          final subOrderId = int.tryParse(id);
          if (subOrderId == null) {
            return const Scaffold(
                body: Center(child: Text('Invalid order request id')));
          }
          return AuthGuard(
            allowedRoles: AppRole.farmerRoles,
            child: OrderDetailPage(
                subOrderId: subOrderId, initialSubOrder: subOrder),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.transportProviderDashboard,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.transportProviderRoles,
          child: ProviderDashboard(),
        ),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.operationalRoles,
          child: NotificationsPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.orderHistory,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: OrderHistoryPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.orders,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: OrderHistoryPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.productCatalog,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: ProductCatalogPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.products,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: ProductCatalogPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.productDetail,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          final extra = state.extra;
          Product? product;
          if (extra is Product) product = extra;
          if (uuid == null)
            return const Scaffold(
                body: Center(child: Text('Missing product id')));
          return AuthGuard(
            allowedRoles: AppRole.buyerRoles,
            child:
                ProductDetailPage(productUuid: uuid, initialProduct: product),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.cart,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: CartPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.addressPicker,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: AddressPickerPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.checkout,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: CheckoutPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.orderConfirmation,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null) {
            return const Scaffold(
                body: Center(child: Text('Missing order id')));
          }
          return AuthGuard(
            allowedRoles: AppRole.buyerRoles,
            child: OrderConfirmationPage(orderUuid: uuid),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.dispute,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.buyerRoles,
          child: DisputePage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.profile,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.operationalRoles,
          child: ProfilePage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.operationalRoles,
          child: settings_page.SettingsPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.support,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.operationalRoles,
          child: support_page.SupportPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.orderTracking,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null)
            return const Scaffold(
                body: Center(child: Text('Missing order id')));
          return AuthGuard(
            allowedRoles: AppRole.operationalRoles,
            child: OrderTrackingPage(orderUuid: uuid),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.availableOrders,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.transportProviderRoles,
          child: AvailableOrdersPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.myTrips,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.transportProviderRoles,
          child: MyTripsPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.tripDetail,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null)
            return const Scaffold(body: Center(child: Text('Missing trip id')));
          return AuthGuard(
            allowedRoles: AppRole.transportProviderRoles,
            child: TripDetailPage(tripUuid: uuid),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.pickup,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null)
            return const Scaffold(body: Center(child: Text('Missing trip id')));
          return AuthGuard(
            allowedRoles: AppRole.transportProviderRoles,
            child: PickupPage(tripUuid: uuid),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.delivery,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'];
          if (uuid == null)
            return const Scaffold(body: Center(child: Text('Missing trip id')));
          return AuthGuard(
            allowedRoles: AppRole.transportProviderRoles,
            child: DeliveryPage(tripUuid: uuid),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.transportEarnings,
        builder: (_, __) => const AuthGuard(
          allowedRoles: AppRole.transportProviderRoles,
          child: TransportEarningsPage(),
        ),
      ),
      GoRoute(
        path: '/404',
        builder: (_, __) => const NotFoundPage(),
      ),
    ],
    errorBuilder: (_, __) => const NotFoundPage(),
  );

  /// Handle deep links and authentication redirects
  /// Deep links are parsed from incoming URIs (from notifications, app links, etc.)
  /// and routed appropriately based on user authentication state and deep link type
  String? _handleDeepLinksAndAuth(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;
    final path = state.uri.path;
    final isPublicAuthRoute = path == RoutePaths.splash ||
        path == RoutePaths.welcome ||
        path == RoutePaths.login ||
        path == RoutePaths.otp ||
        path == RoutePaths.roleSelect ||
        path == RoutePaths.success ||
        path == RoutePaths.register ||

        path == RoutePaths.forgotPassword ||
        path.startsWith('${RoutePaths.register}/');

    if (path == RoutePaths.splash) {
      if (authState is AuthAuthenticated) {
        return AppRole.homePathFor(authState.role);
      }
      return null;
    }

    if (isPublicAuthRoute) {
      if (authState is AuthAuthenticated &&
          (path == RoutePaths.welcome ||
              path == RoutePaths.login ||
              path == RoutePaths.otp ||
              path == RoutePaths.roleSelect ||
              path == RoutePaths.register ||
              path == RoutePaths.forgotPassword ||
              path.startsWith('${RoutePaths.register}/'))) {
        return AppRole.homePathFor(authState.role);
      }
      return null;
    }

    // First, try to parse deep link from the incoming URI
    final deepLinkInfo = DeepLinkHandler.parseUri(state.uri);
    if (deepLinkInfo.type != DeepLinkType.unknown) {
      // User must be authenticated to access deep-linked content
      if (authState is AuthAuthenticated) {
        final routePath = deepLinkInfo.toRoutePath();
        if (routePath != null) {
          debugPrint('[AppRouter] Deep link redirect to: $routePath');
          return routePath;
        }
      } else if (authState is AuthUnauthenticated) {
        // Not authenticated; store deep link and redirect to login
        _storedDeepLink = deepLinkInfo;
        debugPrint('[AppRouter] Stored deep link for post-login redirect');
        return RoutePaths.login;
      }
    }

    // Standard authentication redirects
    if (authState is AuthAuthenticated) {
      final role = authState.role;
      const knownRoutes = <String>{
        RoutePaths.login,
        RoutePaths.splash,
        RoutePaths.welcome,
        RoutePaths.otp,
        RoutePaths.roleSelect,
        RoutePaths.success,
        RoutePaths.register,
        RoutePaths.forgotPassword,
        RoutePaths.buyerDashboard,
        RoutePaths.farmerDashboard,
        RoutePaths.transportProviderDashboard,
        RoutePaths.availableOrders,
        RoutePaths.myTrips,
        RoutePaths.transportEarnings,
        RoutePaths.farmerProducts,
        RoutePaths.farmerProductCreate,
        RoutePaths.farmerOrderRequests,
        RoutePaths.farmerEarnings,
        RoutePaths.notifications,
        RoutePaths.orderHistory,
        RoutePaths.orders,
        RoutePaths.productCatalog,
        RoutePaths.products,
        RoutePaths.cart,
        RoutePaths.checkout,
        RoutePaths.dispute,
        RoutePaths.profile,
        RoutePaths.settings,
        RoutePaths.support,
      };

      if (path == RoutePaths.splash) return AppRole.homePathFor(role);
      if (AppRole.isHomePathForRole(path, role)) return null;
      if (path == RoutePaths.login ||
          path == RoutePaths.welcome ||
          path == RoutePaths.otp ||
          path == RoutePaths.roleSelect ||
          path == RoutePaths.register ||
          path == RoutePaths.forgotPassword ||
          path.startsWith('${RoutePaths.register}/')) {
        return AppRole.homePathFor(role);
      }
      if (!knownRoutes.contains(path) &&
          !path.startsWith('${RoutePaths.productDetail.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.orderTracking.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.tripDetail.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.pickup.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.delivery.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.farmerProductEdit.replaceAll(':uuid', '')}') &&
          !path.startsWith('${RoutePaths.farmerOrderRequestDetail.replaceAll(':id', '')}')) {
        return '/404';
      }
      return null;
    } else if (authState is AuthUnauthenticated) {
      if (isPublicAuthRoute) {
        return null;
      }
      return RoutePaths.login;
    }
    return null;
  }

  /// Get stored deep link (used after successful authentication)
  DeepLinkInfo? getStoredDeepLink() {
    return _storedDeepLink;
  }

  /// Clear stored deep link after navigation
  void clearStoredDeepLink() {
    _storedDeepLink = null;
  }

  /// Static variable to store deep link for post-login redirect
  static DeepLinkInfo? _storedDeepLink;
}
```

## `mobile/lib/core/constants.dart`

```dart
// mobile/lib/core/constants.dart

import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

String getApiBaseUrl() {
  if (dotenv.isInitialized) {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;
  }
  if (kApiBaseUrl.isNotEmpty) return kApiBaseUrl;
  if (Platform.isIOS) return 'http://127.0.0.1:8000';
  if (Platform.isAndroid) return 'http://10.0.2.2:8000';
  return 'http://127.0.0.1:8000';
}

// Auth endpoints
const String kRegisterInitEndpoint = '/api/users/register/init/';
const String kRegisterVerifyEndpoint = '/api/users/register/verify/';
const String kLoginEndpoint = '/api/users/login/';
const String kProfileEndpoint = '/api/users/profile/';
const String kForgotPasswordInitEndpoint = '/api/users/password-reset/init/';
const String kForgotPasswordVerifyEndpoint = '/api/users/password-reset/verify/';
const String kRefreshTokenEndpoint = '/api/token/refresh/';

// Notification constants
const String kNotificationChannelId = 'mambonami_channel';
const String kNotificationChannelName = 'MAMBONAMI Notifications';

// Timeouts
const Duration kApiConnectTimeout = Duration(seconds: 30);
const Duration kApiReceiveTimeout = Duration(seconds: 30);

// Local cache keys
const String kThemeModeKey = 'theme_mode';
const String kNotificationsEnabledKey = 'notifications_enabled';
const String kOrderUpdatesEnabledKey = 'order_updates_enabled';
const String kAppLocaleKey = 'app_locale';
const String kCachedProfileKey = 'cached_user_profile';
const String kUserTable = 'users';
const String kProductTable = 'products';
const String kCartItemTable = 'cart_items';
const String kAddressTable = 'saved_addresses';
// Product cache TTL
const Duration kProductCacheTTL = Duration(hours: 6);

// Auth endpoints
const String kPasswordChangeEndpoint = '/api/users/password-change/';
```


## Events to add in `lib/blocs/order/order_event.dart`

```dart
class FetchBuyerOrdersEvent extends OrderEvent {}
class FetchOrderDetailsEvent extends OrderEvent {
  final String orderId;
  FetchOrderDetailsEvent({required this.orderId});
}
class ConfirmPaymentEvent extends OrderEvent {
  final String orderId;
  ConfirmPaymentEvent({required this.orderId});
}
```

## Events to add in `lib/blocs/product/product_event.dart`

```dart
class FetchProductsEvent extends ProductEvent {}
class SearchProductsEvent extends ProductEvent {
  final String query;
  SearchProductsEvent({required this.query});
}
class FilterProductsByCategoryEvent extends ProductEvent {
  final String category;
  FilterProductsByCategoryEvent({required this.category});
}
class SortProductsEvent extends ProductEvent {
  final String sortBy;
  SortProductsEvent({required this.sortBy});
}
```

## Events to add in `lib/blocs/trip/trip_event.dart`

```dart
class VerifyDeliveryOtpEvent extends TripEvent {
  final String orderId;
  final String otp;
  VerifyDeliveryOtpEvent({required this.orderId, required this.otp});
}
```
