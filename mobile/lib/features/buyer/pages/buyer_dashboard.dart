import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/cart_action_button.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    String username = '';
    if (authState is AuthAuthenticated) {
      username = authState.username ?? authState.phone;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Buyer Dashboard',
        showNotificationAction: true,
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        actions: const [CartActionButton()],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.85)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $username',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 10),
                    Text(
                      'Order fresh produce, follow deliveries, and manage your shopping with confidence.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () => context.push(RoutePaths.products),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      child: const Text('Browse products'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  _DashboardCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Browse Products',
                    subtitle: 'Discover fresh goods',
                    color: Colors.blue,
                    onTap: () => context.push(RoutePaths.products),
                  ),
                  _DashboardCard(
                    icon: Icons.receipt_long,
                    title: 'My Orders',
                    subtitle: 'Track order history',
                    color: Colors.orange,
                    onTap: () => context.push(RoutePaths.orders),
                  ),
                  _DashboardCard(
                    icon: Icons.support_agent,
                    title: 'Support',
                    subtitle: 'Submit a request',
                    color: Colors.green,
                    onTap: () => context.push(RoutePaths.support),
                  ),
                  _DashboardCard(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    subtitle: 'Latest updates',
                    color: Colors.purple,
                    onTap: () => context.push(RoutePaths.notifications),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: Theme.of(context).shadowColor.withOpacity(0.12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 36, color: color),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.75))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
