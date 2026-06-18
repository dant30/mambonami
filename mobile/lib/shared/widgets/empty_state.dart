// mobile/lib/shared/widgets/empty_state.dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String? title;
  final String? description;
  final String? message;

  final String? assetPath;
  final IconData? icon;

  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    this.title,
    this.description,
    this.message,
    this.assetPath,
    this.icon,
    this.buttonText,
    this.onButtonPressed,
  }) : assert(
          title != null || message != null,
          'Provide at least a title or message',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveTitle = title ?? 'Nothing here yet';
    final effectiveDescription =
        description ?? message ?? 'There is no content to display right now.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVisual(theme),
            const SizedBox(height: 20),

            /// Title
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            /// Description
            Text(
              effectiveDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.65),
                height: 1.4,
              ),
            ),

            /// Action Button
            if (onButtonPressed != null && buttonText != null) ...[
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisual(ThemeData theme) {
    /// Priority: asset > icon > default icon
    if (assetPath != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Image.asset(
          assetPath!,
          height: 140,
          fit: BoxFit.contain,
        ),
      );
    }

    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Icon(
        icon ?? Icons.inbox_outlined,
        size: 40,
        color: theme.colorScheme.primary.withOpacity(0.7),
      ),
    );
  }
}