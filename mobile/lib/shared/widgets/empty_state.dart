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
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.94, end: 1.0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildVisual(theme),
              const SizedBox(height: 20),

              Text(
                effectiveTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                effectiveDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.68),
                  height: 1.45,
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: onButtonPressed != null && buttonText != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: ElevatedButton(
                          onPressed: onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(buttonText!),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOut,
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.16),
            theme.colorScheme.primary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon ?? Icons.inbox_outlined,
        size: 42,
        color: theme.colorScheme.primary.withOpacity(0.78),
      ),
    );
  }
}