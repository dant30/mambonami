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
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.clipBehavior = Clip.antiAlias,
    this.shadowColor,
    this.width,
    this.height,
    this.alignment,
    this.enableRipple = true,
    this.isGlass = false,
    this.blur = 12,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedRadius = borderRadius.resolve(Directionality.of(context));
    final effectiveBorder = border ??
        BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.72),
        );
    final backgroundColor = isGlass
        ? (color ?? theme.colorScheme.surface).withValues(alpha: opacity)
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
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: shadowColor ??
                      theme.shadowColor.withValues(alpha: 0.08),
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
          splashFactory:
              enableRipple ? InkRipple.splashFactory : NoSplash.splashFactory,
          child: Container(
            alignment: alignment,
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );

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
