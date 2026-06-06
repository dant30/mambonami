import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget {
  final String? name;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const GreetingHeader({
    super.key,
    this.name,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Hello';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (name != null && name!.isNotEmpty) ? name! : 'there';
    final theme = Theme.of(context);
    final style = textStyle ??
        theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface,
        );

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Icon(
              Icons.waving_hand_outlined,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${_greeting()}, $displayName',
              style: style,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
