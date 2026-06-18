// mobile/lib/shared/widgets/pill_badge.dart
import 'package:flutter/material.dart';

class PillBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  final EdgeInsetsGeometry padding;
  final IconData? icon;

  final bool uppercase;
  final bool outlined;
  final bool enabled;

  final double iconSize;
  final double spacing;
  final VoidCallback? onTap;

  const PillBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.icon,
    this.uppercase = true,
    this.outlined = false,
    this.enabled = true,
    this.iconSize = 16,
    this.spacing = 6,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseColor = foregroundColor ?? theme.colorScheme.primary;

    final bgColor = outlined
        ? Colors.transparent
        : (backgroundColor ??
            baseColor.withValues(alpha: enabled ? 0.12 : 0.06));

    final fgColor = enabled
        ? baseColor
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    final effectiveBorderColor =
        borderColor ?? baseColor.withValues(alpha: 0.3);

    final text = uppercase ? label.toUpperCase() : label;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: fgColor),
          SizedBox(width: spacing),
        ],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );

    final pill = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: outlined
            ? Border.all(color: effectiveBorderColor)
            : null,
      ),
      child: content,
    );

    // Add tap support with ripple
    if (onTap != null && enabled) {
      return Semantics(
        button: true,
        label: text,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: pill,
          ),
        ),
      );
    }

    return Semantics(
      label: text,
      child: pill,
    );
  }
}