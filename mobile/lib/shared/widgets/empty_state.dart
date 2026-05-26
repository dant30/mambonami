import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String? title;
  final String? description;
  final String? message;
  final String? assetPath;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    this.title,
    this.description,
    this.message,
    this.assetPath,
    this.buttonText = 'Retry',
    this.onButtonPressed,
  }) : assert(title != null || message != null, 'Provide title or message');

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? 'Nothing to show';
    final effectiveDescription = description ?? message ?? 'There is no content to display right now.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (assetPath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Image.asset(assetPath!, height: 160),
            ),
          Text(
            effectiveTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            effectiveDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (onButtonPressed != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onButtonPressed,
              child: Text(buttonText),
            ),
          ],
        ],
      ),
    );
  }
}
