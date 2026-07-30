import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/order/order_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/utils/dashboard_data_utils.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/greeting_header.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';
import '../../../data/models/order.dart';
import '../../../data/models/product.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final orderState = context.watch<OrderBloc>().state;
    final productState = context.watch<ProductBloc>().state;

    String username = 'Farmer';
    String? avatarUrl;
    if (authState is AuthAuthenticated) {
      username = authState.displayName ?? authState.username ?? authState.phone;
      avatarUrl = authState.avatarUrl;
    }

    final productList =
        productState is ProductLoaded ? productState.products : <Product>[];
    final pendingOrders = orderState is FarmerSubOrdersLoaded
        ? orderState.subOrders.where((o) => o.isPending).length
        : 0;
    final totalRevenue = orderState is FarmerSubOrdersLoaded
        ? calculateFarmerRevenue(orderState.subOrders)
        : 0.0;
    final readyPickupCount = orderState is FarmerSubOrdersLoaded
        ? countReadySubOrders(orderState.subOrders)
        : 0;
    final productCount = productList.length;
    final averageRating = productList.isNotEmpty
        ? productList
                .map((product) => product.averageRating)
                .reduce((a, b) => a + b) /
            productList.length
        : 0.0;
    final recentSubOrders = orderState is FarmerSubOrdersLoaded
        ? orderState.subOrders.take(3).toList()
        : <SubOrder>[];
    final notificationCount = pendingOrders + (productCount > 0 ? 1 : 0);

    // ── Inventory health ──────────────────────────────────────────────────
    final outOfStock = productList.where((p) => p.availableQuantity <= 0).length;
    final lowStock = productList.where((p) => p.availableQuantity > 0 && p.availableQuantity < 20).length;
    final available = productList.where((p) => p.availableQuantity >= 20).length;

    // ── Dynamic greeting subtitle ───────────────────────────────────────
    String greetingSubtitle;
    if (pendingOrders > 0) {
      greetingSubtitle = 'You have $pendingOrders new order${pendingOrders == 1 ? '' : 's'} waiting.';
    } else if (productCount == 0) {
      greetingSubtitle = 'Add your first product to start selling.';
    } else if (lowStock > 0) {
      greetingSubtitle = '$lowStock product${lowStock == 1 ? '' : 's'} are running low on stock.';
    } else {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        greetingSubtitle = 'Good morning! Ready to harvest today?';
      } else if (hour < 17) greetingSubtitle = 'Keep your farm growing this afternoon.';
      else greetingSubtitle = "Let's wrap up today's farm work.";
    }

    String locationLabel = 'Your farm';
    if (productList.isNotEmpty) {
      final matches = productList
          .where((product) =>
              product.location != null && product.location!.isNotEmpty)
          .toList();
      if (matches.isNotEmpty) {
        locationLabel = matches.first.location!;
      }
    }

    return Scaffold(
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            decoration: const BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GreetingHeader(
                        name: username,
                        subtitle: locationLabel,
                        showDate: true,
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        nameStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        subtitleStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () => context.go(RoutePaths.notifications),
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                '$notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => context.go(RoutePaths.profile),
                      child: Avatar(
                        imageUrl: avatarUrl,
                        username: username,
                        firstName: username.split(' ').firstWhere(
                            (value) => value.isNotEmpty,
                            orElse: () => ''),
                        lastName: username.split(' ').length > 1
                            ? username.split(' ').lastWhere(
                                (value) => value.isNotEmpty,
                                orElse: () => '')
                            : null,
                        size: 44,
                        showBorder: true,
                        backgroundColor: Colors.white24,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _WeatherPill(label: '24°C', icon: Icons.thermostat),
                    _WeatherPill(label: '68%', icon: Icons.water_drop),
                    _WeatherPill(label: '12 km/h', icon: Icons.air),
                    _WeatherPill(label: '☀️ Clear', icon: null),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoleHeroCard(
                    title: 'Farm operations',
                    subtitle: greetingSubtitle,
                    icon: Icons.agriculture_rounded,
                    gradient: const LinearGradient(
                      colors: [AppColors.farmerAccent, AppColors.goldAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    actions: [
                      HeroActionButton(
                        label: 'Products',
                        icon: Icons.inventory_2_rounded,
                        onTap: () => context.go(RoutePaths.farmerProducts),
                      ),
                      HeroActionButton(
                        label: 'Orders',
                        icon: Icons.shopping_bag_rounded,
                        onTap: () => context.go(RoutePaths.farmerOrderRequests),
                      ),
                      HeroActionButton(
                        label: 'Earnings',
                        icon: Icons.attach_money_rounded,
                        onTap: () => context.go(RoutePaths.farmerEarnings),
                      ),
                      HeroActionButton(
                        label: 'Add item',
                        icon: Icons.add_rounded,
                        onTap: () => context.go(RoutePaths.farmerProductCreate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DashboardStatStrip(
                    stats: [
                      DashboardStat(
                        label: 'Pending',
                        value: '$pendingOrders',
                        icon: Icons.pending_actions_rounded,
                      ),
                      DashboardStat(
                        label: 'Ready',
                        value: '$readyPickupCount',
                        icon: Icons.storefront_rounded,
                      ),
                      DashboardStat(
                        label: 'In stock',
                        value: '$available',
                        icon: Icons.inventory_2_rounded,
                      ),
                      DashboardStat(
                        label: 'Rating',
                        value: averageRating.toStringAsFixed(1),
                        icon: Icons.star_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Earnings (MTD)',
                                    style: TextStyle(
                                        fontSize: 12, color: AppColors.muted)),
                                Text(
                                  'KES ${totalRevenue.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('▲ 18.3%',
                                  style: TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Mini chart coming soon',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Insights will appear here as the dashboard grows',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Coming Soon',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
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
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _StatCard(
                        label: 'Pending Orders',
                        value: pendingOrders.toString(),
                        insight: pendingOrders > 0 ? '+$pendingOrders since yesterday' : 'No new orders',
                        icon: Icons.pending_actions_outlined,
                        badge: pendingOrders > 0 ? '$pendingOrders new' : null,
                        color: AppColors.primary,
                      ),
                      _StatCard(
                        label: 'Ready Pickup',
                        value: readyPickupCount.toString(),
                        insight: readyPickupCount > 0 ? '+$readyPickupCount packed' : 'All clear',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                      _StatCard(
                        label: 'Listings',
                        value: productCount.toString(),
                        insight: productCount > 0 ? '+$productCount active' : 'Add your first listing',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.secondary,
                      ),
                      _StatCard(
                        label: 'Avg Rating',
                        value: '${averageRating.toStringAsFixed(1)} ★',
                        insight: averageRating >= 4.5 ? 'Top-rated' : 'Growing reputation',
                        icon: Icons.star,
                        color: AppColors.gold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ActionButton(
                        label: 'Add Product',
                        icon: Icons.add,
                        color: AppColors.primary,
                        onTap: () => context.go(RoutePaths.farmerProductCreate),
                      ),
                      _ActionButton(
                        label: 'View Orders',
                        icon: Icons.shopping_bag,
                        color: AppColors.secondary,
                        onTap: () => context.go(RoutePaths.farmerOrderRequests),
                      ),
                      _ActionButton(
                        label: 'Earnings',
                        icon: Icons.wallet,
                        color: AppColors.gold,
                        onTap: () => context.go(RoutePaths.farmerEarnings),
                      ),
                      _ActionButton(
                        label: 'Alerts',
                        icon: Icons.notifications,
                        color: AppColors.supportAccent,
                        onTap: () => context.go(RoutePaths.notifications),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: 'Recent Orders',
                    trailing: TextButton(
                      onPressed: () =>
                          context.go(RoutePaths.farmerOrderRequests),
                      child: const Text('View all'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (recentSubOrders.isEmpty)
                    const CustomCard(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.shopping_bag_outlined),
                        title: Text('No recent orders'),
                        subtitle: Text(
                            'New orders will appear here as they come in.'),
                      ),
                    )
                  else
                    ...recentSubOrders.map((subOrder) {
                      final title = subOrder.items.isNotEmpty
                          ? subOrder.items.first.productName
                          : 'Fresh produce';
                      final subtitle = subOrder.items.isNotEmpty
                          ? '${subOrder.items.length} item${subOrder.items.length == 1 ? '' : 's'} • ${subOrder.status}'
                          : subOrder.status;
                      return CustomCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.shopping_bag_outlined),
                          title: Text(title),
                          subtitle: Text(subtitle),
                          trailing: Text(
                              'KES ${subOrder.subtotal.toStringAsFixed(0)}'),
                          onTap: () =>
                              context.go(RoutePaths.farmerOrderRequests),
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: 'Inventory Overview',
                    trailing: TextButton(
                      onPressed: () => context.go(RoutePaths.farmerProducts),
                      child: const Text('Manage'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (productList.isEmpty)
                    const CustomCard(
                      padding: EdgeInsets.all(12),
                      child: Text(
                          'Add your first product to start filling your inventory view.'),
                    )
                  else
                    ...productList.take(3).map((product) {
                      final quantityLabel =
                          '${product.availableQuantity.toStringAsFixed(0)} ${product.unit.isNotEmpty ? product.unit : 'units'}';
                      final progress = product.availableQuantity > 0
                          ? (product.availableQuantity /
                                  (product.availableQuantity +
                                      product.reservedQuantity))
                              .clamp(0.0, 1.0)
                          : 0.0;
                      return _InventoryTile(
                        name: product.name,
                        quantity: quantityLabel,
                        progress: progress,
                        imageUrl: product.imageUrl,
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String insight;
  final IconData icon;
  final Color color;
  final String? badge;

  const _StatCard({
    required this.label,
    required this.value,
    required this.insight,
    required this.icon,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (badge != null)
                Text(
                  badge!,
                  style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 10),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          const SizedBox(height: 2),
          Text(
            insight,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8)
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherPill extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _WeatherPill({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  final String name;
  final String quantity;
  final double progress;
  final String? imageUrl;

  const _InventoryTile({
    required this.name,
    required this.quantity,
    required this.progress,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.light,
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : null,
            child: imageUrl == null || imageUrl!.isEmpty
                ? const Icon(Icons.agriculture, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(quantity,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Stock Level',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.light,
                  valueColor: AlwaysStoppedAnimation(
                      progress < 0.5 ? AppColors.warning : AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
