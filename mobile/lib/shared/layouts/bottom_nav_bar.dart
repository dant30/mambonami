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
    final backgroundColor = theme.bottomAppBarTheme.color ?? theme.colorScheme.surfaceContainerHighest;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.textTheme.bodySmall?.color?.withAlpha(180) ?? theme.colorScheme.onSurface.withOpacity(0.6),
      selectedLabelStyle: theme.textTheme.bodySmall,
      unselectedLabelStyle: theme.textTheme.bodySmall,
      showUnselectedLabels: true,
      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          activeIcon: Icon(item.activeIcon ?? item.icon),
          label: item.label,
        );
      }).toList(),
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