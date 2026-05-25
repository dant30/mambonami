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
        title: Text(title, style: theme.textTheme.titleLarge),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
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
        title: Text(title, style: theme.textTheme.titleLarge),
        content: Text(message, style: theme.textTheme.bodyMedium),
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