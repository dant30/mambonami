// mobile/lib/features/buyer/pages/buyer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/order/order_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/greeting_header.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final orderState = context.watch<OrderBloc>().state;
    
    String username = '';
    if (authState is AuthAuthenticated) {
      username = authState.username ?? authState.phone;
    }

    // Get recent orders count
    int recentOrdersCount = 0;
    if (orderState is MyOrdersLoaded) {
      recentOrdersCount = orderState.orders.length;
    }

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
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<OrderBloc>().add(FetchMyOrdersEvent());
            context.read<ProductBloc>().add(const FetchProductsEvent());
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              GreetingHeader(
                name: username.isNotEmpty ? username : 'there',
                subtitle: 'Fresh produce delivered to your door',
              ),
              DashboardStatStrip(
                stats: [
                  DashboardStat(
                    label: 'Orders',
                    value: recentOrdersCount.toString(),
                    icon: Icons.receipt_long_outlined,
                  ),
                  DashboardStat(
                    label: 'Active',
                    value: '3',
                    icon: Icons.shopping_bag_outlined,
                  ),
                  DashboardStat(
                    label: 'Saved',
                    value: '12',
                    icon: Icons.favorite_border,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'Quick Actions',
                subtitle: 'Shop, track, and manage your orders',
              ),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _QuickActionTile(
                    icon: Icons.storefront_outlined,
                    title: 'Browse',
                    subtitle: 'Fresh products',
                    color: AppColors.buyerAccent,
                    onTap: () => context.push(RoutePaths.products),
                  ),
                  _QuickActionTile(
                    icon: Icons.shopping_cart_checkout_rounded,
                    title: 'Cart',
                    subtitle: 'Ready to checkout',
                    color: AppColors.secondaryLight,
                    onTap: () => context.push(RoutePaths.cart),
                  ),
                  _QuickActionTile(
                    icon: Icons.receipt_long,
                    title: 'Orders',
                    subtitle: 'Track history',
                    color: AppColors.farmerAccent,
                    onTap: () => context.push(RoutePaths.orders),
                  ),
                  _QuickActionTile(
                    icon: Icons.support_agent,
                    title: 'Support',
                    subtitle: 'We\'re here',
                    color: AppColors.supportAccent,
                    onTap: () => context.push(RoutePaths.support),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Featured',
                subtitle: 'Handpicked for you',
                trailing: TextButton(
                  onPressed: () => context.push(RoutePaths.products),
                  child: const Text('See all'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FeatureCard(
                      icon: Icons.eco,
                      title: 'Organic Week',
                      subtitle: '20% off organic produce',
                      color: AppColors.buyerAccent,
                    ),
                    const SizedBox(width: 12),
                    _FeatureCard(
                      icon: Icons.local_shipping,
                      title: 'Free Delivery',
                      subtitle: 'On orders over KES 2,000',
                      color: AppColors.providerAccent,
                    ),
                    const SizedBox(width: 12),
                    _FeatureCard(
                      icon: Icons.percent,
                      title: 'Farmer Specials',
                      subtitle: 'Direct from farm',
                      color: AppColors.farmerAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.72),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
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
