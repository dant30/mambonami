// mobile/lib/shared/widgets/loading_indicator.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final bool compact;

  /// New features
  final bool fullscreen;
  final bool blurBackground;
  final double? size;
  final Widget? indicator;
  final bool blocking;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.compact = false,
    this.fullscreen = false,
    this.blurBackground = false,
    this.size,
    this.indicator,
    this.blocking = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final indicatorColor = color ?? theme.colorScheme.primary;
    final effectiveSize = size ?? (compact ? 22 : 30);

    Widget loader = Semantics(
      label: message ?? 'Loading',
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        scale: 1,
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: 1,
          child: Container(
            padding: EdgeInsets.all(compact ? 14 : 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: effectiveSize,
                  height: effectiveSize,
                  child: indicator ??
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        color: indicatorColor,
                      ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (!fullscreen) {
      return Center(child: loader);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0.84),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (blocking)
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withValues(alpha: 0.2),
            ),

          if (blurBackground)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: const SizedBox.expand(),
            ),

          Center(child: loader),
        ],
      ),
    );
  }
}