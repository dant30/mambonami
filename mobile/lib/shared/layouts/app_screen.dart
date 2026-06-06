import 'package:flutter/material.dart';

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
    this.useGradientBackground = true,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF07110C),
          Color(0xFF102019),
          Color(0xFF0D1712),
        ],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFEAF8EF),
        Color(0xFFDDF2E5),
        Color(0xFFF3FAF1),
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
