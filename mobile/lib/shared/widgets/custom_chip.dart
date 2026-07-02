// mobile/lib/shared/widgets/custom_chip.dart
import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final Widget? avatar;
  final VoidCallback? onDeleted;
  final bool selected;
  final double? fontSize;

  const CustomChip({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.avatar,
    this.onDeleted,
    this.selected = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selected;
    final bgColor = color ??
        (isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.chipTheme.backgroundColor);
    
    return Chip(
      avatar: avatar,
      label: Text(
        label,
        style: TextStyle(
          fontSize: fontSize ?? 13,
          color: textColor ??
              (isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      backgroundColor: bgColor,
      onDeleted: onDeleted,
      deleteIcon: onDeleted != null
          ? Icon(Icons.close, size: 16)
          : null,
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
        width: isSelected ? 1.5 : 0.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      visualDensity: VisualDensity.compact,
    );
  }
}