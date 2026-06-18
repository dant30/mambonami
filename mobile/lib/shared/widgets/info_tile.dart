// mobile/lib/shared/widgets/info_tile.dart
import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  final EdgeInsetsGeometry padding;
  final bool dense;
  final bool showBorder;
  final bool enableFeedback;

  const InfoTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.dense = false,
    this.showBorder = true,
    this.enableFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final radius = BorderRadius.circular(12);

    final hasLeading = leading != null || icon != null;

    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (icon != null) {
      leadingWidget = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: dense ? 34 : 40,
        height: dense ? 34 : 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: dense ? 18 : 21,
        ),
      );
    }

    return Semantics(
      button: onTap != null,
      label: title,
      child: Material(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          enableFeedback: enableFeedback,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: showBorder
                  ? Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
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

                /// TEXT CONTENT
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

                /// TRAILING
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}