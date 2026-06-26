// mobile/lib/shared/layouts/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  static const _animationDuration = Duration(milliseconds: 220);

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 10,
      shadowColor: theme.shadowColor.withValues(alpha: 0.12),
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.65),
                width: 1,
              ),
            ),
          ),
          child: NavigationBar(
            height: 68,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              HapticFeedback.selectionClick();
              onTap(index);
            },
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: theme.colorScheme.surfaceTint,
            indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.14),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: items.map((item) {
              return NavigationDestination(
                icon: item.badgeCount > 0
                    ? Badge(
                        label: Text(item.badgeCount > 99
                            ? '99+'
                            : item.badgeCount.toString()),
                        child: Icon(item.icon),
                      )
                    : Icon(item.icon),
                selectedIcon: item.badgeCount > 0
                    ? Badge(
                        label: Text(item.badgeCount > 99
                            ? '99+'
                            : item.badgeCount.toString()),
                        child: Icon(item.activeIcon ?? item.icon),
                      )
                    : Icon(item.activeIcon ?? item.icon),
                label: item.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int badgeCount;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badgeCount = 0,
  });
}
