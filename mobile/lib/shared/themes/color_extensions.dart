// lib/shared/themes/color_extensions.dart
import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Convenience helper matching the project's `.withValues(alpha: x)` usage.
  /// Accepts an `alpha` double in 0.0-1.0 and returns a color with that opacity.
  Color withValues({double? alpha}) {
    if (alpha == null) return this;
    return withValues(alpha: alpha);
  }
}
