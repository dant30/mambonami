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
      backgroundColor: color ??
          (selected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.chipTheme.backgroundColor),
      labelStyle: TextStyle(
        color: textColor ??
            (selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface),
        fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
      ),
      onDeleted: onDeleted,
      side: BorderSide(
        color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );
  }
}
