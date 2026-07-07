// mobile/lib/features/buyer/pages/buyer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/order/order_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/order.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/widgets/greeting_header.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/shimmer_grid.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final orderState = context.watch<OrderBloc>().state;
    final productState = context.watch<ProductBloc>().state;

    String username = '';
    if (authState is AuthAuthenticated) {
      username = authState.username ?? authState.phone;
    }

    final orders = orderState is MyOrdersLoaded ? orderState.orders : const <dynamic>[];
    final parsedOrders = orders.whereType<Order>().toList();
    final orderCount = parsedOrders.length;

    Order? activeOrder;
    for (final order in parsedOrders) {
      if (order.status != 'delivered' && order.status != 'cancelled') {
        activeOrder = order;
        break;
      }
    }
    final activeOrderCount = parsedOrders.where((order) {
      return order.status != 'delivered' && order.status != 'cancelled';
    }).length;

    final wishCount = productState is ProductLoaded
        ? productState.products.where((product) => product.isFavorite).length
        : 0;

    final products = productState is ProductLoaded ? productState.products : <Product>[];
    final featuredProducts = products.take(4).toList();

    // Extract unique farmer names for "Nearby farmers"
    final nearbyFarmers = products
        .map((p) => p.farmerName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .take(3)
        .toList();

    final categories = ['All', ...products.map((product) => product.category.code).where((code) => code.isNotEmpty).toSet().toList()]
      ..sort((a, b) => a == 'All' ? -1 : b == 'All' ? 1 : a.compareTo(b));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Fresh Market',
        showNotificationAction: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: const [CartActionButton()],
      ),
      drawer: const AppDrawer(),
      body: AppScreen(
        scrollable: false,
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<OrderBloc>().add(FetchMyOrdersEvent());
            context.read<ProductBloc>().add(const FetchProductsEvent());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // ─── Greeting ──────────────────────────────────────────────
              GreetingHeader(
                name: username.isNotEmpty ? username : 'there',
                subtitle: 'Fresh produce delivered to your door',
              ),

              // ─── Stats Strip ──────────────────────────────────────────
              DashboardStatStrip(
                stats: [
                  DashboardStat(
                    label: 'Orders',
                    value: orderCount.toString(),
                    icon: Icons.receipt_long_outlined,
                  ),
                  DashboardStat(
                    label: 'Active',
                    value: activeOrderCount.toString(),
                    icon: Icons.shopping_bag_outlined,
                  ),
                  DashboardStat(
                    label: 'Saved',
                    value: wishCount.toString(),
                    icon: Icons.favorite_border,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Hero Card ────────────────────────────────────────────
              _HeroCard(
                title: 'Delivering freshness near you',
                subtitle: 'Tap to browse the freshest harvest today',
                icon: Icons.eco_rounded,
                actionLabel: 'Shop now',
                onTap: () => context.push(RoutePaths.products),
              ),
              const SizedBox(height: 16),

              // ─── Search Bar ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  readOnly: true,
                  onTap: () => context.push(RoutePaths.products),
                  decoration: InputDecoration(
                    hintText: 'Search produce, farmers or categories',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Category Chips ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    final isSelected = category == 'All';
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => context.push(RoutePaths.products),
                      selectedColor: AppColors.buyerAccent.withValues(alpha: 0.16),
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // ─── Nearby Farmers ──────────────────────────────────────
              SectionHeader(
                title: 'Nearby farmers',
                subtitle: 'Fresh picks close to your area',
                trailing: TextButton(
                  onPressed: () => context.push(RoutePaths.products),
                  child: const Text('See all'),
                ),
              ),
              const SizedBox(height: 8),
              productState is ProductLoading
                  ? const ShimmerGrid(crossAxisCount: 1, itemHeight: 120)
                  : productState is ProductLoaded && featuredProducts.isEmpty
                      ? _buildSpotlightPlaceholders()
                      : SizedBox(
                          height: 164,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: featuredProducts.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final product = featuredProducts[index];
                              return _SpotlightCard(
                                title: product.farmerName.isNotEmpty
                                    ? product.farmerName
                                    : 'Farm Fresh',
                                subtitle: product.displayName,
                                icon: Icons.agriculture_rounded,
                                accent: AppColors.providerAccent,
                              );
                            },
                          ),
                        ),
              const SizedBox(height: 18),

              // ─── Recommended Products ────────────────────────────────
              SectionHeader(
                title: 'Recommended products',
                subtitle: 'Handpicked for your next order',
                trailing: TextButton(
                  onPressed: () => context.push(RoutePaths.products),
                  child: const Text('Explore'),
                ),
              ),
              const SizedBox(height: 8),
              productState is ProductLoading
                  ? const ShimmerGrid(crossAxisCount: 2, itemHeight: 200)
                  : productState is ProductLoaded && featuredProducts.isEmpty
                      ? _buildFeaturePlaceholders()
                      : SizedBox(
                          height: 220,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: featuredProducts.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final product = featuredProducts[index];
                              return _ProductFeatureCard(
                                product: product,
                                onTap: () =>
                                    context.push(RoutePaths.productDetailPath(product.uuid)),
                              );
                            },
                          ),
                        ),
              const SizedBox(height: 18),

              // ─── Active Order Tracking ──────────────────────────────
              if (activeOrder != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _DeliveryProgressCard(order: activeOrder!),
                ),
              const SizedBox(height: 16),

              // ─── Summary Card ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SummaryCard(
                  title: 'This week',
                  subtitle: 'Your market activity is looking healthy',
                  value: 'KES ${orderCount * 1800}',
                  detail: '${activeOrderCount} delivery windows booked',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  Widget _buildSpotlightPlaceholders() {
    return SizedBox(
      height: 164,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          return _SpotlightCard(
            title: index == 0 ? 'Organic box' : 'Wet market',
            subtitle: index == 0 ? 'Vegetables and greens' : 'Fresh staples today',
            icon: index == 0 ? Icons.grass : Icons.storefront_rounded,
            accent: index == 0 ? AppColors.buyerAccent : AppColors.farmerAccent,
          );
        },
      ),
    );
  }

  Widget _buildFeaturePlaceholders() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          return _FeatureCard(
            icon: index == 0 ? Icons.eco : Icons.local_shipping,
            title: index == 0 ? 'Organic Week' : 'Free Delivery',
            subtitle: index == 0 ? 'Kales, tomatoes and herbs' : 'Orders over KES 2,000',
            color: index == 0 ? AppColors.buyerAccent : AppColors.providerAccent,
          );
        },
      ),
    );
  }
}

// ─── Hero Card ──────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onTap;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.buyerAccent, AppColors.providerAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                actionLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Spotlight Card ─────────────────────────────────────────────────────────

class _SpotlightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _SpotlightCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const Spacer(),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Delivery Progress Card ─────────────────────────────────────────────────

class _DeliveryProgressCard extends StatelessWidget {
  final Order order;

  const _DeliveryProgressCard({required this.order});

  double _computeProgress(String status) {
    const steps = [
      'placed',
      'paidEscrow',
      'farmerConfirmed',
      'farmerReady',
      'transportAssigned',
      'pickedUp',
      'delivered'
    ];
    final index = steps.indexOf(status);
    if (index < 0) return 0;
    return (index + 1) / steps.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _computeProgress(order.status);
    final statusLabel = order.status == 'delivered'
        ? 'Delivered'
        : order.status == 'cancelled'
            ? 'Cancelled'
            : 'In progress';
    final color = order.status == 'delivered'
        ? AppColors.success
        : order.status == 'cancelled'
            ? AppColors.error
            : AppColors.providerAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: color),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    context.push(RoutePaths.orderTrackingPath(order.uuid)),
                child: const Text('Track'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.deliveryAddress.isNotEmpty
                ? order.deliveryAddress
                : 'Your order is on the way',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.status == 'delivered'
                ? 'Delivered successfully'
                : order.status == 'cancelled'
                    ? 'Order cancelled'
                    : 'Packed • On route • Near you',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Card ────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String detail;

  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.buyerAccent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Feature Card ────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Product Feature Card ────────────────────────────────────────────────────

class _ProductFeatureCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductFeatureCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.72)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.buyerAccent.withValues(alpha: 0.12),
                          child: const Center(
                            child: Icon(Icons.eco, size: 40, color: AppColors.buyerAccent),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.buyerAccent.withValues(alpha: 0.12),
                        child: const Center(
                          child: Icon(Icons.eco, size: 40, color: AppColors.buyerAccent),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (product.isOrganic)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Organic',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Icon(
                        product.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: product.isFavorite
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (product.promoLabel != null && product.promoLabel!.isNotEmpty)
                    Text(
                      product.promoLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'KES ${product.pricePerUnit.toStringAsFixed(0)}/${product.unit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  if (product.distanceKm != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '≈ ${product.distanceKm!.toStringAsFixed(1)} km away',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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