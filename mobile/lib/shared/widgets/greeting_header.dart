// mobile/lib/shared/widgets/greeting_header.dart
import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget {
  final String? name;
  final String? subtitle;
  final TextStyle? textStyle;
  final TextStyle? subtitleStyle;
  final EdgeInsetsGeometry padding;
  final bool animate;

  const GreetingHeader({
    super.key,
    this.name,
    this.subtitle,
    this.textStyle,
    this.subtitleStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
    this.animate = true,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Hello';
  }

  String _emoji() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '🌅';
    if (hour >= 12 && hour < 17) return '☀️';
    if (hour >= 17 && hour < 21) return '🌆';
    return '🌙';
  }

  IconData _icon() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return Icons.wb_sunny_outlined;
    if (hour >= 12 && hour < 17) return Icons.wb_cloudy_outlined;
    if (hour >= 17 && hour < 21) return Icons.nightlight_round;
    return Icons.waving_hand_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        (name != null && name!.trim().isNotEmpty) ? name!.trim() : 'there';

    final theme = Theme.of(context);

    final titleStyle = textStyle ??
        theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
        );

    final subStyle = subtitleStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              _emoji(),
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_greeting()}, $displayName',
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: subStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: padding,
      child: animate
          ? TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: content,
            )
          : content,
    );
  }
}