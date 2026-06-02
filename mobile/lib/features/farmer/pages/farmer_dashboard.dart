import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/themes/app_theme_extension.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/widgets/greeting_header.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../blocs/auth/auth_bloc.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>();
    final greetingGradient = extension?.heroGradient ?? LinearGradient(
      colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.75)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    String username = 'Farmer';
    if (authState is AuthAuthenticated) {
      username = authState.username ?? authState.phone ?? 'Farmer';
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Farmer Dashboard', showNotificationAction: true, leading: IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingHeader(name: username),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.92,
              children: [
                _DashboardCard(
                  icon: Icons.inventory_outlined,
                  label: 'My Products',
                  description: 'View and manage your catalog',
                  color: Colors.blue,
                  onTap: () => context.push(RoutePaths.farmerProducts),
                ),
                _DashboardCard(
                  icon: Icons.add_circle_outline,
                  label: 'Add Product',
                  description: 'Create a new listing',
                  color: Colors.orange,
                  onTap: () => context.push(RoutePaths.farmerProductCreate),
                ),
                _DashboardCard(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Order Requests',
                  description: 'Confirm and fulfill orders',
                  color: Colors.green,
                  onTap: () => context.push(RoutePaths.farmerOrderRequests),
                ),
                _DashboardCard(
                  icon: Icons.show_chart_outlined,
                  label: 'Earnings',
                  description: 'Track farm revenue',
                  color: Colors.purple,
                  onTap: () => context.push(RoutePaths.farmerEarnings),
                ),
              ],
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
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: theme.shadowColor.withOpacity(0.12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 16),
              Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
              const Spacer(),
              Row(
                children: [
                  Text('Manage now', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
