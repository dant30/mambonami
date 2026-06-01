import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/widgets/greeting_header.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String username = '';
    if (authState is AuthAuthenticated) {
      username = authState.username ?? authState.phone;
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Transport Provider',
        showNotificationAction: true,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingHeader(name: username),
            const SizedBox(height: 24),
            _buildQuickAccessCards(context),
            const SizedBox(height: 24),
            _buildStatsSection(context),
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
        Text(
          'Quick Access',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _QuickAccessCard(
              title: 'Available Orders',
              icon: Icons.shopping_bag,
              color: Colors.blue,
              onTap: () => context.push(RoutePaths.availableOrders),
            ),
            _QuickAccessCard(
              title: 'My Trips',
              icon: Icons.route,
              color: Colors.orange,
              onTap: () => context.push(RoutePaths.myTrips),
            ),
            _QuickAccessCard(
              title: 'Earnings',
              icon: Icons.attach_money,
              color: Colors.green,
              onTap: () => context.push(RoutePaths.transportEarnings),
            ),
            _QuickAccessCard(
              title: 'Profile',
              icon: Icons.person,
              color: Colors.purple,
              onTap: () => context.push(RoutePaths.profile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: 'Trips', value: '0'),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.withOpacity(0.3),
                ),
                _StatItem(label: 'Earnings', value: 'Ksh 0'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
