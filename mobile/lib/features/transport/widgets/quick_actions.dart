// mobile/lib/features/transport/widgets/quick_actions.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';

class QuickActions extends StatelessWidget {
  final bool hasActiveTrip;

  const QuickActions({super.key, required this.hasActiveTrip});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Available', 'icon': Icons.inventory_2_outlined, 'route': RoutePaths.availableOrders, 'color': AppColors.providerAccent},
      {'label': 'Trips', 'icon': Icons.local_shipping_outlined, 'route': RoutePaths.myTrips, 'color': AppColors.primaryDark},
      {'label': 'Wallet', 'icon': Icons.attach_money_rounded, 'route': RoutePaths.transportEarnings, 'color': AppColors.gold},
      {'label': 'Vehicle', 'icon': Icons.directions_car_rounded, 'route': RoutePaths.transportVehicle, 'color': AppColors.secondary},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.dark),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: items.map((item) {
            return _QuickActionTile(
              label: item['label'] as String,
              icon: item['icon'] as IconData,
              accentColor: item['color'] as Color,
              onTap: () => context.push(item['route'] as String),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: accentColor.withValues(alpha: 0.25), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}