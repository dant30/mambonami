// mobile/lib/shared/widgets/custom_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final Widget? icon;

  final VoidCallback? onPressed;

  final bool isLoading;
  final bool enabled;

  final Color? color;
  final Color? textColor;
  final Color? disabledColor;

  final double borderRadius;
  final EdgeInsetsGeometry padding;

  final ButtonStyle? style;

  final bool fullWidth;
  final double? height;
  final double? minWidth;

  final bool outlined;
  final String? loadingText;

  const CustomButton({
    super.key,
    this.label,
    this.child,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.color,
    this.textColor,
    this.disabledColor,
    this.borderRadius = 8.0,
    this.padding =
        const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
    this.style,
    this.fullWidth = true,
    this.height,
    this.minWidth,
    this.outlined = false,
    this.loadingText,
  }) : assert(label != null || child != null,
            'Provide either label or child');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveHeight = height ?? 50.0;

    final isDisabled = !enabled || isLoading;

    final bgColor = outlined
        ? Colors.transparent
        : (enabled
            ? (color ?? theme.colorScheme.primary)
            : (disabledColor ??
                theme.disabledColor.withValues(alpha: 0.3)));

    final fgColor = textColor ??
        (outlined
            ? theme.colorScheme.primary
            : theme.colorScheme.onPrimary);

    final borderSide = outlined
        ? BorderSide(
            color: enabled
                ? (color ?? theme.colorScheme.primary)
                : theme.disabledColor,
          )
        : BorderSide.none;

    final defaultStyle = ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      disabledForegroundColor:
          theme.colorScheme.onSurface.withValues(alpha: 0.38),
      elevation: outlined ? 0 : 0,
      minimumSize: Size(
        fullWidth ? double.infinity : (minWidth ?? 120),
        effectiveHeight,
      ),
      padding: padding,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: borderSide,
      ),
    );

    final content = isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(fgColor),
                ),
              ),
              if (loadingText != null) ...[
                const SizedBox(width: 10),
                Text(
                  loadingText!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          )
        : child ??
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  label!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            );

    final button = ElevatedButton(
      onPressed: isDisabled
          ? null
          : () {
              try {
                HapticFeedback.lightImpact();
              } catch (_) {}
              onPressed?.call();
            },
      style: style != null
          ? defaultStyle.merge(style)
          : defaultStyle,
      child: content,
    );

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: label,
      child: fullWidth
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}
