import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = color ?? theme.colorScheme.primary;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: textColor, strokeWidth: 3),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
