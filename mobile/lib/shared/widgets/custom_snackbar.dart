import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSecondary),
        ),
        backgroundColor: backgroundColor ?? theme.colorScheme.secondary,
        duration: duration,
        behavior: behavior,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message, backgroundColor: Theme.of(context).colorScheme.primary);
  }

  static void showError(BuildContext context, String message) {
    show(context, message, backgroundColor: Theme.of(context).colorScheme.error);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message, backgroundColor: Theme.of(context).colorScheme.secondary);
  }
}