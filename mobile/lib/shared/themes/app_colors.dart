// mobile/lib/shared/themes/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===========================================================================
  // BRAND
  // ===========================================================================

  static const Color primary = Color(0xFF1B7F3B);
  static const Color primaryLight = Color(0xFF1B7F3B);
  static const Color primaryDark = Color(0xFF4EC36F);

  static const Color secondary = Color(0xFF2FA84F);
  static const Color secondaryLight = secondary;
  static const Color secondaryDark = Color(0xFF61C97C);

  static const Color gold = Color(0xFFD4AF37);
  static const Color goldAccent = Color(0xFFF3E2A7);

  static const Color primaryGreen = primary;

  static const Color primaryForegroundLight = Colors.white;
  static const Color primaryForegroundDark = Color(0xFF062311);

  static const Color secondaryForegroundLight = Color(0xFF072911);
  static const Color secondaryForegroundDark = Color(0xFF072911);

  // ===========================================================================
  // LIGHT THEME
  // ===========================================================================

  static const Color backgroundLight = Color(0xFFF7FAF7);

  static const Color background = backgroundLight;
  static const Color light = backgroundLight;

  static const Color foregroundLight = Color(0xFF0F1F15);
  static const Color textDark = Color(0xFF172A1D);

  static const Color dark = foregroundLight;

  static const Color textMuted = Color(0xFF5A7A63);

  static const Color muted = textMuted;

  static const Color cardLight = Colors.white;

  static const Color surfaceHighLight = Color(0xFFE8F2EB);

  static const Color outlineLight = Color(0xFFDCE8DE);

  static const Color inputLight = Color(0xFFF4F8F2);

  // ===========================================================================
  // DARK THEME
  // ===========================================================================

  static const Color backgroundDark = Color(0xFF0F1712);

  static const Color foregroundDark = Color(0xFFF2F8F2);

  static const Color cardDark = Color(0xFF17241C);

  static const Color surfaceHighDark = Color(0xFF22362A);

  static const Color outlineDark = Color(0xFF324A3A);

  static const Color inputDark = Color(0xFF1C2A21);

  // ===========================================================================
  // SEMANTIC
  // ===========================================================================

  static const Color success = Color(0xFF22C55E);

  static const Color warning = Color(0xFFF59E0B);

  static const Color error = Color(0xFFEF4444);

  static const Color lightGreen = Color(0xFFE8F8EE);
  static const Color secondaryGreen = secondary;
  static const Color transportPurple = Color(0xFF4C1D95);

  static const Color destructiveLight = error;

  static const Color destructiveDark = Color(0xFFFF6B6B);

  static const Color destructiveForegroundLight = Colors.white;

  static const Color destructiveForegroundDark = Colors.white;

  // ===========================================================================
  // ROLE COLORS
  // ===========================================================================

  static const Color buyerAccent = secondary;

  static const Color farmerAccent = gold;

  static const Color providerAccent = Color(0xFF2F7FA1);

  static const Color supportAccent = Color(0xFF6D28D9);

  // ===========================================================================
  // COMMON
  // ===========================================================================

  static const Color white = Colors.white;

  static const Color black = Colors.black;

  static const Color transparent = Colors.transparent;

  // ===========================================================================
  // FOCUS
  // ===========================================================================

  static const Color ringLight = primary;

  static const Color ringDark = primaryDark;

  static const Color focus = primary;
}

// Convenience extension used across the UI for opacity shorthand.
extension ColorExtensions on Color {
  /// Convenience helper matching the project's `.withValues(alpha: x)` usage.
  /// Accepts an `alpha` double in 0.0-1.0 and returns a color with that opacity.
  Color withValues({double? alpha}) {
    if (alpha == null) return this;
    return withOpacity(alpha);
  }
}