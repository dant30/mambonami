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
      {'label': 'Deliveries', 'icon': Icons.local_shipping_outlined, 'route': RoutePaths.myTrips, 'color': AppColors.providerAccent},
      {'label': 'Wallet', 'icon': Icons.wallet_rounded, 'route': RoutePaths.transportEarnings, 'color': AppColors.farmerAccent},
      {'label': 'Vehicle', 'icon': Icons.directions_car_rounded, 'route': RoutePaths.profile, 'color': AppColors.buyerAccent},
      {'label': 'Support', 'icon': Icons.help_outline_rounded, 'route': RoutePaths.support, 'color': AppColors.supportAccent},
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}