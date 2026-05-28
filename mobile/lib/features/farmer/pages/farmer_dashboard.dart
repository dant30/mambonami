import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/greeting_header.dart';
import '../../../blocs/auth/auth_bloc.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String username = '';
    if (authState is AuthAuthenticated) {
      username = authState.username ?? authState.phone;
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Farmer Dashboard', showNotificationAction: true),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingHeader(name: username),
            const SizedBox(height: 12),
            Text(
              'Manage produce, review orders, and keep your farm business moving.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  _DashboardCard(
                    icon: Icons.inventory_outlined,
                    label: 'My Products',
                    description: 'View and manage your catalog',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => context.go(RoutePaths.farmerProducts),
                  ),
                  _DashboardCard(
                    icon: Icons.add_circle_outline,
                    label: 'Add Product',
                    description: 'Create a new listing',
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () => context.go(RoutePaths.farmerProductCreate),
                  ),
                  _DashboardCard(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Order Requests',
                    description: 'Confirm and fulfill orders',
                    color: Colors.orange.shade700,
                    onTap: () => context.go(RoutePaths.farmerOrderRequests),
                  ),
                  _DashboardCard(
                    icon: Icons.show_chart_outlined,
                    label: 'Earnings',
                    description: 'Track your revenue',
                    color: Colors.green.shade700,
                    onTap: () => context.go(RoutePaths.farmerEarnings),
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
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 18),
              Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text('Manage now', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
