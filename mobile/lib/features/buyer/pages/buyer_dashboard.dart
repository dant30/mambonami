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