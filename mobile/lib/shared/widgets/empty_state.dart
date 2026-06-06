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
    final effectiveDescription =
        description ?? message ?? 'There is no content to display right now.';
    final theme = Theme.of(context);

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
            )
          else
            Container(
              width: 76,
              height: 76,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Icon(
                Icons.eco_outlined,
                color: theme.colorScheme.primary,
                size: 34,
              ),
            ),
          Text(
            effectiveTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            effectiveDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.66),
              height: 1.4,
            ),
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
