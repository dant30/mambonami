// mobile/lib/features/transport/widgets/hero_card.dart
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';

class HeroCard extends StatelessWidget {
  final int activeTrips;
  final double todayEarnings;
  final String username;
  final bool isOnline;
  final int availableOrdersCount;
  final VoidCallback onToggleOnline;
  final VoidCallback onAvailable;
  final VoidCallback onMyTrips;
  final VoidCallback onEarnings;

  const HeroCard({
    super.key,
    required this.activeTrips,
    required this.todayEarnings,
    required this.username,
    required this.isOnline,
    required this.availableOrdersCount,
    required this.onToggleOnline,
    required this.onAvailable,
    required this.onMyTrips,
    required this.onEarnings,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : (hour < 17 ? 'Good Afternoon' : 'Good Evening');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.logistics,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $username',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOnline ? AppColors.success.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isOnline ? '● Online' : '● Offline',
                            style: TextStyle(
                              color: isOnline ? AppColors.success : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (availableOrdersCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$availableOrdersCount new',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Online toggle
              Row(
                children: [
                  const Icon(
                    Icons.circle_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onToggleOnline,
                    child: Container(
                      width: 48,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isOnline ? AppColors.success : Colors.grey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroActionTile(
                  label: 'Available',
                  icon: Icons.inventory_2_outlined,
                  onTap: onAvailable,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroActionTile(
                  label: 'My Trips',
                  icon: Icons.route_outlined,
                  onTap: onMyTrips,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroActionTile(
                  label: 'Earnings',
                  icon: Icons.attach_money_rounded,
                  onTap: onEarnings,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.today_rounded, size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Today: KES ${todayEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
                    SizedBox(width: 4),
                    Text(
                      '4.9 ★',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HeroActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}