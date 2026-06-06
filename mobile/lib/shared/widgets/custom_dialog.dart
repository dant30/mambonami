import 'package:flutter/material.dart';

class CustomDialog {
  static Future<void> showInfo(
    BuildContext context,
    String title,
    String message, {
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) {
    final theme = Theme.of(context);
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        icon: _DialogIcon(
          icon: Icons.info_outline,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirm(
    BuildContext context,
    String title,
    String message, {
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    bool barrierDismissible = true,
  }) {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        icon: _DialogIcon(
          icon: Icons.help_outline,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

class _DialogIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _DialogIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
