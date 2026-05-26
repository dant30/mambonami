import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final Widget? avatar;
  final VoidCallback? onDeleted;
  final bool selected;

  const CustomChip({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.avatar,
    this.onDeleted,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: avatar,
      label: Text(label),
      backgroundColor: color ?? theme.chipTheme.backgroundColor,
      labelStyle: TextStyle(
        color: textColor ?? theme.chipTheme.labelStyle?.color,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      onDeleted: onDeleted,
      side: selected ? BorderSide(color: theme.colorScheme.primary) : null,
    );
  }
}