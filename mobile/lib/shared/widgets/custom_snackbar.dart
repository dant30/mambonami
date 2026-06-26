// mobile/lib/shared/widgets/custom_snackbar.dart
import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    Widget? leading,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final effectiveBackground = backgroundColor ?? theme.colorScheme.primary;
    final foreground = ThemeData.estimateBrightnessForColor(effectiveBackground) == Brightness.dark
        ? Colors.white
        : Colors.white;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            leading ?? Icon(
              Icons.eco_outlined,
              color: foreground,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: effectiveBackground,
        duration: duration,
        behavior: behavior,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: foreground,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void showPersistent(
    BuildContext context,
    String message, {
      Color? backgroundColor,
      Widget? leading,
      String? actionLabel,
      VoidCallback? onAction,
    }) {
    show(
      context,
      message,
      backgroundColor: backgroundColor,
      duration: const Duration(days: 1),
      leading: leading,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message, backgroundColor: Theme.of(context).colorScheme.primary);
  }

  static void showError(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
      leading: const Icon(Icons.error_outline, color: Colors.white, size: 20),
    );
  }

  static void showWarning(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.orange,
      leading: const Icon(Icons.warning_amber_outlined, color: Colors.white, size: 20),
    );
  }

  static void showInfo(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      leading: const Icon(Icons.info_outline, color: Colors.white, size: 20),
    );
  }
}