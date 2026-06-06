import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.iconColor,
    this.backgroundColor,
    this.size = 24,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(10.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRadius = borderRadius.clamp(0, 8).toDouble();
    final button = Material(
      color:
          backgroundColor ?? theme.colorScheme.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(effectiveRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(effectiveRadius),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Padding(
            padding: padding,
            child: Icon(
              icon,
              size: size,
              color: iconColor ?? theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
