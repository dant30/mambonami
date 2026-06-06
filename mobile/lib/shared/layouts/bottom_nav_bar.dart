// mobile/lib/shared/layouts/bottom_nav_bar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.7)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          destinations: items.map((item) {
            return NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.activeIcon ?? item.icon),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}
