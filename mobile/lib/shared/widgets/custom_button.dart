// mobile/lib/shared/widgets/custom_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_colors.dart';

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

  /// New: use gold gradient instead of green
  final bool gold;

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
    this.borderRadius = 24.0, // changed to match prototype
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
    this.style,
    this.fullWidth = true,
    this.height,
    this.minWidth,
    this.outlined = false,
    this.loadingText,
    this.gold = false,
  }) : assert(label != null || child != null, 'Provide either label or child');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveHeight = height ?? 54.0;

    final isDisabled = !enabled || isLoading;

    // Determine background color/gradient
    final bgColor = outlined
        ? Colors.transparent
        : (enabled
            ? (color ?? (gold ? AppColors.gold : AppColors.primary))
            : (disabledColor ?? theme.disabledColor.withValues(alpha: 0.3)));

    final fgColor = textColor ??
        (outlined
            ? AppColors.primary
            : (gold ? Colors.white : theme.colorScheme.onPrimary));

    final borderSide = outlined
        ? BorderSide(
            color: enabled
                ? (color ?? AppColors.primary)
                : theme.disabledColor,
          )
        : BorderSide.none;

    // Build gradient if needed
    Widget? gradientWidget;
    if (!outlined && enabled && !gold) {
      // We can't directly put gradient on ElevatedButton, but we can wrap with Container
      // We'll handle via style using background builder? Actually we can use Container as parent.
      // Simpler: we'll use Container with gradient and then place button with transparent bg.
    }

    // We'll use the existing style approach: for filled buttons we wrap with Container to apply gradient.
    // But to keep it simple and avoid breaking existing usage, we'll handle the gradient via Container and transparent button.

    Widget buttonContent = isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      fgColor),
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

    // Build the button
    Widget button = ElevatedButton(
      onPressed: isDisabled
          ? null
          : () {
              try {
                HapticFeedback.lightImpact();
              } catch (_) {}
              onPressed?.call();
            },
      style: style != null
          ? (style!.merge(ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius)),
              minimumSize: Size(
                fullWidth ? double.infinity : (minWidth ?? 120),
                effectiveHeight,
              ),
              padding: padding,
            )))
          : ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius)),
              minimumSize: Size(
                fullWidth ? double.infinity : (minWidth ?? 120),
                effectiveHeight,
              ),
              padding: padding,
            ),
      child: buttonContent,
    );

    // If not outlined and not disabled, wrap with gradient container
    if (!outlined && enabled) {
      final gradientColors = gold
          ? [const Color(0xFFE8C547), AppColors.gold]
          : [AppColors.secondary, AppColors.primary];
      button = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: (gold ? AppColors.gold : AppColors.primary)
                  .withValues(alpha: 0.35),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: button,
      );
    } else if (outlined) {
      // Outline button: apply border via style already
      // We'll just ensure the button style has the border.
      button = ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: (style ?? ElevatedButton.styleFrom()).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(fgColor),
          side: WidgetStateProperty.all(
              const BorderSide(color: AppColors.primary, width: 2)),
          shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius))),
          minimumSize: WidgetStateProperty.all(Size(
              fullWidth ? double.infinity : (minWidth ?? 120),
              effectiveHeight)),
          padding: WidgetStateProperty.all(padding),
        ),
        child: buttonContent,
      );
    }

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