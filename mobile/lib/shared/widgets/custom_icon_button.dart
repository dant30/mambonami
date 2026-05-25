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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(icon, size: size, color: iconColor ?? theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
