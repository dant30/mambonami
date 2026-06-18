// mobile/lib/shared/widgets/custom_card.dart
// mobile/lib/shared/widgets/custom_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final VoidCallback? onTap;

  final double elevation;
  final Color? color;
  final Gradient? gradient;

  final BorderSide? border;
  final BorderRadiusGeometry borderRadius;

  final Clip clipBehavior;
  final Color? shadowColor;

  final double? width;
  final double? height;

  final AlignmentGeometry? alignment;

  final bool enableRipple;

  /// 🌟 Glassmorphism options
  final bool isGlass;
  final double blur;
  final double opacity;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation = 0,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.clipBehavior = Clip.antiAlias,
    this.shadowColor,
    this.width,
    this.height,
    this.alignment,
    this.enableRipple = true,

    // 🌟 glass defaults
    this.isGlass = false,
    this.blur = 12,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasElevation = elevation > 0;

    /// ✅ FIX: Resolve BorderRadiusGeometry
    final resolvedRadius =
        borderRadius.resolve(Directionality.of(context));

    final effectiveBorder = border ??
        BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        );

    final backgroundColor = isGlass
        ? (color ?? theme.colorScheme.surface)
            .withOpacity(opacity)
        : (gradient == null ? color ?? theme.colorScheme.surface : null);

    Widget content = Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: isGlass ? null : gradient,
        borderRadius: resolvedRadius,
        border: Border.fromBorderSide(effectiveBorder),
        boxShadow: hasElevation
            ? [
                BoxShadow(
                  color:
                      shadowColor ?? Colors.black.withOpacity(0.08),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: resolvedRadius,
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          borderRadius: resolvedRadius,
          splashFactory: enableRipple
              ? InkRipple.splashFactory
              : NoSplash.splashFactory,
          child: Container(
            alignment: alignment,
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );

    /// 🌟 Apply glass effect
    if (isGlass) {
      content = ClipRRect(
        borderRadius: resolvedRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    return content;
  }
}