import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/order/order_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/utils/dashboard_data_utils.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/section_header.dart';
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
      appBar: CustomAppBar(
        title: 'Farmer Dashboard',
        showNotificationAction: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Good morning 🌅',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          username,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 12, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(locationLabel,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.go(RoutePaths.notifications),
                          icon: const Icon(Icons.notifications_none,
                              color: Colors.white),
                        ),
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
                            size: 36,
                            showBorder: false,
                            backgroundColor: Colors.white24,
                            textStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Wrap(
                  spacing: 12,
                  children: [
                    Chip(
                        label: Text('24°C'),
                        avatar: Icon(Icons.thermostat, size: 14)),
                    Chip(
                        label: Text('68%'),
                        avatar: Icon(Icons.water_drop, size: 14)),
                    Chip(
                        label: Text('12 km/h'),
                        avatar: Icon(Icons.air, size: 14)),
                    Chip(label: Text('☀️ Clear')),
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
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Earnings trend unavailable in this build',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.muted,
                                  ),
                            ),
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
                        icon: Icons.pending_actions_outlined,
                        badge: pendingOrders > 0 ? '$pendingOrders new' : null,
                        color: AppColors.primary,
                      ),
                      _StatCard(
                        label: 'Ready Pickup',
                        value: readyPickupCount.toString(),
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                      _StatCard(
                        label: 'Listings',
                        value: productCount.toString(),
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.secondary,
                      ),
                      _StatCard(
                        label: 'Avg Rating',
                        value: '${averageRating.toStringAsFixed(1)} ★',
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
  final IconData icon;
  final Color color;
  final String? badge;

  const _StatCard({
    required this.label,
    required this.value,
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
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8)
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ],
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
