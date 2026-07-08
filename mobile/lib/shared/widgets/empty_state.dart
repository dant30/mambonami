// mobile/lib/shared/widgets/empty_state.dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String? title;
  final String? description;
  final String? message;
  final String? subtitle;
  final String? emoji;

  final String? assetPath;
  final IconData? icon;

  final String? buttonText;
  final String? actionLabel;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    this.title,
    this.description,
    this.message,
    this.subtitle,
    this.emoji,
    this.assetPath,
    this.icon,
    this.buttonText,
    this.actionLabel,
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
        description ?? message ?? subtitle ?? 'There is no content to display right now.';
    final effectiveButtonText = buttonText ?? actionLabel;

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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                  height: 1.45,
                ),
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: onButtonPressed != null && effectiveButtonText != null
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(effectiveButtonText!),
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

    if (emoji != null) {
      return Text(emoji!, style: const TextStyle(fontSize: 44));
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOut,
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.16),
            theme.colorScheme.primary.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon ?? Icons.inbox_outlined,
        size: 42,
        color: theme.colorScheme.primary.withValues(alpha: 0.78),
      ),
    );
  }
}
