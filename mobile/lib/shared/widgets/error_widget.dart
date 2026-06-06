import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final String? assetPath;

  const AppErrorWidget({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.buttonText,
    this.onRetry,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (assetPath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Image.asset(assetPath!, height: 150),
            ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.24),
              ),
            ),
            child: Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
              height: 1.4,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(buttonText ?? 'Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
