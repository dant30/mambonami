import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final ButtonStyle? style;

  const CustomButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.color,
    this.textColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
    this.style,
  }) : assert(label != null || child != null, 'Provide label or child');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: style ?? ElevatedButton.styleFrom(
          backgroundColor: enabled ? color ?? theme.colorScheme.primary : theme.disabledColor,
          foregroundColor: textColor ?? theme.colorScheme.onPrimary,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor ?? theme.colorScheme.onPrimary),
                ),
              )
            : child ?? Text(
                label!,
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600) ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
