// mobile/lib/features/transport/pages/provider_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/widgets/greeting_header.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/trip/trip_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/trip.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/role_dashboard_widgets.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final tripState = context.watch<TripBloc>().state;
    String username = '';
    if (authState is AuthAuthenticated) {
      username = authState.username ?? authState.phone;
    }

    final trips = tripState is MyTripsLoaded ? tripState.trips : <Trip>[];
    String activeTripLabel = '';
    if (trips.isNotEmpty) {
      final activeTrip = trips.where((trip) => trip.status.toLowerCase() != 'delivered' && trip.status.toLowerCase() != 'cancelled').isNotEmpty
          ? trips.where((trip) => trip.status.toLowerCase() != 'delivered' && trip.status.toLowerCase() != 'cancelled').first
          : null;
      if (activeTrip != null) {
        activeTripLabel = 'You have an active trip in ${activeTrip.status}. Tap to continue.';
      }
    }
    final activeTrips = trips.where((trip) => trip.status.toLowerCase() != 'delivered' && trip.status.toLowerCase() != 'cancelled').length;
    final earnings = trips.fold<double>(0.0, (sum, trip) => sum + (trip.agreedFee ?? 0.0));
    final statusLabel = activeTrips > 0 ? 'Active' : 'Ready';

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Transport Provider',
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
            if (activeTripLabel.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.providerAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.providerAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route_outlined, color: AppColors.providerAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activeTripLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(RoutePaths.myTrips),
                      child: const Text('View'),
                    ),
                  ],
                ),
              ),
            ],
            RoleHeroCard(
              title: 'Delivery control',
              subtitle: activeTrips > 0
                  ? 'You currently have $activeTrips trip${activeTrips == 1 ? '' : 's'} in motion. Open your queue to continue.'
                  : 'Claim available orders, manage pickup flow, and complete delivery verification with confidence.',
              icon: Icons.local_shipping_outlined,
              gradient: AppGradients.logistics,
              actions: [
                HeroActionButton(
                  label: 'Available',
                  icon: Icons.inventory_2_outlined,
                  onTap: () => context.push(RoutePaths.availableOrders),
                ),
                HeroActionButton(
                  label: 'My Trips',
                  icon: Icons.route_outlined,
                  onTap: () => context.push(RoutePaths.myTrips),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildQuickAccessCards(context),
            const SizedBox(height: 18),
            _buildStatsSection(context, activeTrips: activeTrips, earnings: earnings, statusLabel: statusLabel),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  Widget _buildQuickAccessCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Access',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.92,
          children: [
            DashboardActionTile(
              title: 'Available Orders',
              subtitle: 'Claim pickups',
              icon: Icons.shopping_bag,
              accentColor: AppColors.providerAccent,
              onTap: () => context.push(RoutePaths.availableOrders),
            ),
            DashboardActionTile(
              title: 'My Trips',
              subtitle: 'Active routes',
              icon: Icons.route,
              accentColor: AppColors.buyerAccent,
              onTap: () => context.push(RoutePaths.myTrips),
            ),
            DashboardActionTile(
              title: 'Earnings',
              subtitle: 'Provider income',
              icon: Icons.attach_money,
              accentColor: AppColors.farmerAccent,
              onTap: () => context.push(RoutePaths.transportEarnings),
            ),
            DashboardActionTile(
              title: 'Profile',
              subtitle: 'Account details',
              icon: Icons.person,
              accentColor: AppColors.supportAccent,
              onTap: () => context.push(RoutePaths.profile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, {required int activeTrips, required double earnings, required String statusLabel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s Overview',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        DashboardStatStrip(
          stats: [
            DashboardStat(
              label: 'Trips',
              value: activeTrips.toString(),
              icon: Icons.route_outlined,
            ),
            DashboardStat(
              label: 'Earnings',
              value: 'Ksh ${earnings.toStringAsFixed(0)}',
              icon: Icons.payments_outlined,
            ),
            DashboardStat(
              label: 'Status',
              value: statusLabel,
              icon: Icons.verified_outlined,
            ),
          ],
        ),
      ],
    );
  }
}
