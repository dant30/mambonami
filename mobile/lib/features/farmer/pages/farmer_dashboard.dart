import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/widgets/greeting_header.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    String username = 'Farmer';
    if (authState is AuthAuthenticated) {
      username = authState.username ?? authState.phone;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Farmer Dashboard',
        showNotificationAction: true,
        leading: Builder(
          builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer()),
        ),
      ),
      drawer: const AppDrawer(),
      body: AppScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingHeader(name: username),
            const SizedBox(height: 10),
            RoleHeroCard(
              title: 'Farm operations',
              subtitle:
                  'Manage listings, prepare order requests, and keep earnings visible in one focused workspace.',
              icon: Icons.agriculture_outlined,
              gradient: AppGradients.field,
              actions: [
                HeroActionButton(
                  label: 'Add Product',
                  icon: Icons.add_rounded,
                  onTap: () => context.push(RoutePaths.farmerProductCreate),
                ),
                HeroActionButton(
                  label: 'Requests',
                  icon: Icons.assignment_turned_in_outlined,
                  onTap: () => context.push(RoutePaths.farmerOrderRequests),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const DashboardStatStrip(
              stats: [
                DashboardStat(
                  label: 'Listings',
                  value: 'Active',
                  icon: Icons.inventory_2_outlined,
                ),
                DashboardStat(
                  label: 'Requests',
                  value: 'Open',
                  icon: Icons.task_alt_outlined,
                ),
                DashboardStat(
                  label: 'Revenue',
                  value: 'Ready',
                  icon: Icons.show_chart_rounded,
                ),
              ],
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.92,
              children: [
                DashboardActionTile(
                  icon: Icons.inventory_outlined,
                  title: 'My Products',
                  subtitle: 'Manage catalog',
                  accentColor: AppColors.farmerAccent,
                  onTap: () => context.push(RoutePaths.farmerProducts),
                ),
                DashboardActionTile(
                  icon: Icons.add_circle_outline,
                  title: 'Add Product',
                  subtitle: 'Create listing',
                  accentColor: AppColors.secondaryLight,
                  onTap: () => context.push(RoutePaths.farmerProductCreate),
                ),
                DashboardActionTile(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Order Requests',
                  subtitle: 'Confirm and fulfill',
                  accentColor: AppColors.buyerAccent,
                  onTap: () => context.push(RoutePaths.farmerOrderRequests),
                ),
                DashboardActionTile(
                  icon: Icons.show_chart_outlined,
                  title: 'Earnings',
                  subtitle: 'Track revenue',
                  accentColor: Colors.purple,
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
