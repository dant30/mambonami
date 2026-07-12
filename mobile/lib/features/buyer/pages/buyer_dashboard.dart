// lib/features/buyer/pages/buyer_dashboard.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/notification/notification_bloc.dart';
import '../../../blocs/order/order_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/order.dart';
import '../../../data/models/product.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/utils/dashboard_data_utils.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/product_grid_tile.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
    'Roots',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const FetchProductsEvent());
    context.read<OrderBloc>().add(FetchBuyerOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    // Compute unread count from NotificationBloc state
    final notifState = context.watch<NotificationBloc>().state;
    final unreadCount = notifState is NotificationLoaded
        ? notifState.notifications.where((n) => n.isUnread).length
        : 0;

    // Active order from OrderBloc
    final orderState = context.watch<OrderBloc>().state;
    final activeOrder = orderState is BuyerOrdersLoaded ? orderState.activeOrder : null;
    final productState = context.watch<ProductBloc>().state;
    final products = productState is ProductLoaded ? productState.products : <Product>[];

    final userLocation = (activeOrder?.deliveryCity.isNotEmpty ?? false)
        ? activeOrder!.deliveryCity
        : (products.where((product) => product.location != null && product.location!.isNotEmpty).isNotEmpty
            ? products.where((product) => product.location != null && product.location!.isNotEmpty).first.location!
            : 'Your preferred delivery location');
    final nearbyFarmers = buildNearbyFarmers(products);
    final featuredProducts = products.take(6).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            _buildHeader(
              context,
              authState: authState,
              location: userLocation,
              unreadCount: unreadCount,
            ),

            // ── Scrollable content ──────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero banner
                      _buildHeroBanner(context, products: products),
                      const SizedBox(height: 16),

                      // Category chips
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CategoryChipBar(
                          categories: _categories,
                          selected: _selectedCategoryIndex,
                          onSelected: (i) {
                            setState(() => _selectedCategoryIndex = i);
                            // For simplicity, navigate to catalog when a category is selected
                            // In a real app, you could filter products.
                            context.go(RoutePaths.productCatalog);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nearby farmers
                      _buildNearbyFarmers(context, farmers: nearbyFarmers),
                      const SizedBox(height: 20),

                      // Recommended products grid
                      BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          if (state is ProductLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }
                          if (state is ProductLoaded) {
                            return _buildProductGrid(context, products: featuredProducts);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Active order tracking strip
                      if (activeOrder != null)
                        _buildActiveOrderStrip(context, activeOrder),
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

  // ── Header with location, search, avatar ──────────────────────
  Widget _buildHeader(
    BuildContext context, {
    required AuthState authState,
    required String location,
    required int unreadCount,
  }) {
    final theme = Theme.of(context);
    final userName = authState is AuthAuthenticated
        ? authState.username ?? authState.phone
        : 'Guest';
    final avatarLabel = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';

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
                  onTap: () => context.go(RoutePaths.addressPicker),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery to',
                        style: theme.textTheme.bodySmall?.copyWith(
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
                            style: theme.textTheme.titleSmall?.copyWith(
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
                  if (unreadCount > 0)
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
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      avatarLabel,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar
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
                    style: theme.textTheme.bodyMedium?.copyWith(
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

  // ── Hero banner ─────────────────────────────────────────────────
  Widget _buildHeroBanner(BuildContext context, {required List<Product> products}) {
    final theme = Theme.of(context);
    final featuredProduct = products.isNotEmpty ? products.first : null;
    final bannerTitle = featuredProduct != null
        ? 'Fresh from ${featuredProduct.farmerName}'
        : 'Fresh from the Farm';
    final bannerSubtitle = featuredProduct != null
        ? '${featuredProduct.name} is now available'
        : 'Up to 30% off today';

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
              errorWidget: (_, __, ___) => Container(
                height: 148,
                color: AppColors.light,
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: AppColors.muted),
                ),
              ),
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
                  Text('Fresh picks',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    bannerTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(bannerSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
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

  // ── Nearby farmers horizontal row ─────────────────────────────
  Widget _buildNearbyFarmers(BuildContext context, {required List<Map<String, String>> farmers}) {
    final theme = Theme.of(context);

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
                        imageUrl: f['image'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.light,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.agriculture, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      f['name'] ?? 'Nearby farm',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      f['distance'] ?? 'Nearby',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.muted,
                        fontSize: 9,
                      ),
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

  // ── Recommended products grid ──────────────────────────────────
  Widget _buildProductGrid(BuildContext context, {required List<Product> products}) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Text(
            'No products available at the moment.',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }

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
          itemCount: products.length.clamp(0, 6),
          itemBuilder: (context, i) => ProductGridTile(product: products[i]),
        ),
      ],
    );
  }

  // ── Active order tracking strip ───────────────────────────────
  Widget _buildActiveOrderStrip(BuildContext context, Order order) {
    final theme = Theme.of(context);
    final statusLabel = order.statusLabel;
    final distanceLabel = order.totalDistanceKm != null
        ? '${order.totalDistanceKm!.toStringAsFixed(1)} km away'
        : 'On the route';
    final etaLabel = order.etaMinutes != null ? '${order.etaMinutes} min' : 'soon';
    final completedSteps = order.isDelivered ? 5 : (order.status.toLowerCase().contains('picked') ? 4 : (order.status.toLowerCase().contains('assigned') ? 3 : 2));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Your Active Order'),
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        statusLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress steps
                _buildStepProgress(completedSteps),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.navigation_rounded,
                        size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text.rich(
                      TextSpan(
                        style: theme.textTheme.bodySmall,
                        children: [
                          const TextSpan(text: 'Driver is '),
                          TextSpan(
                            text: distanceLabel,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark),
                          ),
                          const TextSpan(text: ' · ETA '),
                          TextSpan(
                            text: etaLabel,
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

  // ── 5‑step progress indicator ──────────────────────────────────
  Widget _buildStepProgress(int completed) {
    const steps = ['Placed', 'Confirmed', 'Pickup', 'On way', 'Done'];
    final safeCompleted = completed.clamp(0, steps.length);
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
                    color: i < safeCompleted - 1
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

  // ── Refresh data ──────────────────────────────────────────────────
  Future<void> _refreshData() async {
    context.read<ProductBloc>().add(const FetchProductsEvent());
    context.read<OrderBloc>().add(FetchBuyerOrdersEvent());
    return Future.value();
  }
}