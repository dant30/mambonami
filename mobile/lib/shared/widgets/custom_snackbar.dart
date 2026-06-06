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
        content: Row(
          children: [
            Icon(
              Icons.eco_outlined,
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        duration: duration,
        behavior: behavior,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message,
        backgroundColor: Theme.of(context).colorScheme.primary);
  }

  static void showError(BuildContext context, String message) {
    show(context, message,
        backgroundColor: Theme.of(context).colorScheme.error);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message,
        backgroundColor: Theme.of(context).colorScheme.secondary);
  }
}
