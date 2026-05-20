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
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
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
