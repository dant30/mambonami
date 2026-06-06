import 'package:flutter/material.dart';

class PillBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;

  const PillBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        backgroundColor ?? theme.colorScheme.primary.withValues(alpha: 0.12);
    final fgColor = foregroundColor ?? theme.colorScheme.primary;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
