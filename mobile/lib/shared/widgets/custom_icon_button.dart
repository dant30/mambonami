// mobile/lib/shared/widgets/custom_icon_button.dart
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
  final bool isLoading;
  final bool isSelected;

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
    this.isLoading = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInteractive = onPressed != null && !isLoading;
    
    Widget button = Material(
      color: backgroundColor ??
          (isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent),
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: isInteractive ? onPressed : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                : null,
          ),
          child: isLoading
              ? SizedBox(
                  width: size,
                  height: size,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  icon,
                  size: size,
                  color: iconColor ??
                      (isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface),
                ),
        ),
      ),
    );

    if (tooltip != null && isInteractive) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}