import 'package:flutter/material.dart';

import '../themes/app_theme_extension.dart';

class AppScreen extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final bool useGradientBackground;
  final ScrollPhysics? physics;

  const AppScreen({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 20),
    this.scrollable = true,
    this.useGradientBackground = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final resolvedPadding = padding.add(EdgeInsets.only(bottom: bottomInset));

    final content = scrollable
        ? SingleChildScrollView(
            physics: physics,
            padding: resolvedPadding,
            child: child,
          )
        : Padding(
            padding: resolvedPadding,
            child: child,
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        gradient: useGradientBackground ? _backgroundGradient(context) : null,
      ),
      child: content,
    );
  }

  LinearGradient _backgroundGradient(BuildContext context) {
    final theme = Theme.of(context);
    final extension = theme.extension<AppThemeExtension>();
    if (extension != null) {
      return extension.heroGradient;
    }

    return theme.brightness == Brightness.dark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F1712),
              Color(0xFF16251B),
              Color(0xFF101713),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7FAF5),
              Color(0xFFEEF6EC),
              Color(0xFFF9FBF7),
            ],
          );
  }
}

class AppPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: child,
    );
  }
}
