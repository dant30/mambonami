// mobile/lib/shared/layouts/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/notification_badge.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showNotificationAction;
  final Color? backgroundColor;
  final bool centerTitle;
  final double elevation;
  final String? fallbackRoute;
  final VoidCallback? fallbackOnPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.leading,
    this.actions,
    this.showNotificationAction = false,
    this.backgroundColor,
    this.centerTitle = true,
    this.elevation = 0,
    this.fallbackRoute,
    this.fallbackOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      titleSpacing: 12,
      elevation: elevation,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: leading ??
          ((showBackButton &&
                  (Navigator.of(context).canPop() ||
                      fallbackOnPressed != null ||
                      fallbackRoute != null))
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                      return;
                    }
                    if (fallbackOnPressed != null) {
                      fallbackOnPressed!();
                      return;
                    }
                    if (fallbackRoute != null) {
                      context.go(fallbackRoute!);
                    }
                  },
                )
              : null),
      actions: [
        if (actions != null) ...actions!,
        if (showNotificationAction)
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child:
                SizedBox(width: 44, child: Center(child: NotificationBadge())),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
