// lib/shared/widgets/info_tile.dart

import 'package:flutter/material.dart';
import '../themes/app_radius.dart';

/// A versatile info tile with optional leading icon, subtitle, and trailing widget.
/// Designed for settings pages, account menus, and feature lists.
class InfoTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// External margin around the tile (use to space multiple tiles).
  final EdgeInsetsGeometry margin;

  /// Internal padding inside the tile.
  final EdgeInsetsGeometry padding;

  /// Compact mode – smaller leading icon, tighter spacing.
  final bool dense;

  /// Whether to show a subtle border around the tile.
  final bool showBorder;

  /// Whether the InkWell should provide feedback (ripple).
  final bool enableFeedback;

  /// Custom text color for the title (useful for destructive actions).
  final Color? textColor;

  const InfoTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 4),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.dense = false,
    this.showBorder = true,
    this.enableFeedback = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const borderRadius = AppRadius.lg;

    // ── Leading widget ──────────────────────────────────────────────────────
    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (icon != null) {
      final size = dense ? 34.0 : 40.0;
      final iconSize = dense ? 18.0 : 22.0;
      leadingWidget = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: iconSize,
        ),
      );
    }

    // ── Trailing widget ────────────────────────────────────────────────────
    Widget? trailingWidget;
    if (trailing != null) {
      trailingWidget = trailing;
    } else if (onTap != null) {
      trailingWidget = Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      );
    }

    return Semantics(
      button: onTap != null,
      label: title,
      child: Padding(
        padding: margin,
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: borderRadius,
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            enableFeedback: enableFeedback,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: showBorder
                    ? Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        width: 0.8,
                      )
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leadingWidget != null) ...[
                    leadingWidget,
                    const SizedBox(width: 12),
                  ],

                  // ── Text content ────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: (dense
                                  ? theme.textTheme.bodyMedium
                                  : theme.textTheme.titleSmall)
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textColor ?? theme.colorScheme.onSurface,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Trailing ────────────────────────────────────────────
                  if (trailingWidget != null) ...[
                    const SizedBox(width: 8),
                    trailingWidget,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}