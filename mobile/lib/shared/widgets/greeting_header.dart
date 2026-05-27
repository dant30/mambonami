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
        theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700);

    return Padding(
      padding: padding,
      child: Text(
        '${_greeting()}, $displayName',
        style: style,
      ),
    );
  }
}
