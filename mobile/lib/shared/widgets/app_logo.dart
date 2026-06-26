import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final EdgeInsetsGeometry padding;

  const AppLogo({
    super.key,
    this.size = 44,
    this.showWordmark = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mark = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset(
        'assets/icons/logo.png',
        fit: BoxFit.contain,
        semanticLabel: 'Mambonami logo',
      ),
    );

    return Padding(
      padding: padding,
      child: showWordmark
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                mark,
                const SizedBox(width: 10),
                Text(
                  'MAMBONAMI',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ],
            )
          : mark,
    );
  }
}
