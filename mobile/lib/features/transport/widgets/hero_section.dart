// mobile/lib/features/transport/widgets/hero_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/greeting_header.dart';

class HeroSection extends StatelessWidget {
  final String username;
  final String subtitle;
  final bool isOnline;
  final int activeTrips;
  final int availableOrdersCount;
  final double todayEarnings;
  final String? avatarUrl;
  final String? weather;

  final VoidCallback onToggleOnline;
  final VoidCallback onAvailable;
  final VoidCallback onMyTrips;
  final VoidCallback onEarnings;

  const HeroSection({
    super.key,
    required this.username,
    required this.subtitle,
    required this.isOnline,
    required this.activeTrips,
    required this.availableOrdersCount,
    required this.todayEarnings,
    required this.onToggleOnline,
    required this.onAvailable,
    required this.onMyTrips,
    required this.onEarnings,
    this.avatarUrl,
    this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: Greeting + Notification + Avatar ────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GreetingHeader(
                  name: username,
                  subtitle: subtitle,
                  showDate: true,
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  nameStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  subtitleStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => context.push(RoutePaths.notifications),
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  // Unread badge can be added here if needed
                ],
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => context.go(RoutePaths.profile),
                child: Avatar(
                  imageUrl: avatarUrl,
                  username: username,
                  firstName: username.split(' ').firstWhere(
                        (value) => value.isNotEmpty,
                        orElse: () => '',
                      ),
                  lastName: username.split(' ').length > 1
                      ? username.split(' ').lastWhere(
                          (value) => value.isNotEmpty,
                          orElse: () => '',
                        )
                      : null,
                  size: 44,
                  showBorder: true,
                  backgroundColor: Colors.white24,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Status pills ──────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: isOnline ? '● Online' : '● Offline',
                color: isOnline ? AppColors.success : Colors.grey,
              ),
              if (availableOrdersCount > 0)
                _StatusPill(
                  label: '$availableOrdersCount new',
                  color: AppColors.gold,
                ),
              _StatusPill(
                label: activeTrips == 1 ? '1 active trip' : '$activeTrips active trips',
                color: AppColors.providerAccent,
              ),
              if (weather != null)
                _StatusPill(
                  label: weather!,
                  color: Colors.white70,
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Switch.adaptive(
                      value: isOnline,
                      activeColor: AppColors.success,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (_) => onToggleOnline(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Action Tiles ──────────────────────────────────────────
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
          const SizedBox(height: 12),

          // ── Today earnings & rating ──────────────────────────────
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

// ─── Helper widgets ────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
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