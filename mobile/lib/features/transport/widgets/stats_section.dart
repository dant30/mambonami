// mobile/lib/features/transport/widgets/stats_section.dart
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';

class StatsSection extends StatelessWidget {
  final int activeTrips;
  final double earnings;
  final double todayEarnings;
  final String statusLabel;
  final String weather;

  const StatsSection({
    super.key,
    required this.activeTrips,
    required this.earnings,
    required this.todayEarnings,
    required this.statusLabel,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Overview",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.dark),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Trips',
                value: activeTrips.toString(),
                icon: Icons.route_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Today',
                value: 'KES ${todayEarnings.toStringAsFixed(0)}',
                icon: Icons.today_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Status',
                value: statusLabel,
                icon: Icons.verified_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceHighLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, color: AppColors.warning, size: 16),
              const SizedBox(width: 6),
              Text(
                weather,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.muted),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}