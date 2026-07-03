// mobile/lib/shared/themes/app_theme_extension.dart
import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final LinearGradient heroGradient;
  final LinearGradient warmGradient;
  final List<BoxShadow> softShadow;
  final List<BoxShadow> glowShadow;
  final Color ringColor;

  const AppThemeExtension({
    required this.heroGradient,
    required this.warmGradient,
    required this.softShadow,
    required this.glowShadow,
    required this.ringColor,
  });

  @override
  AppThemeExtension copyWith({
    LinearGradient? heroGradient,
    LinearGradient? warmGradient,
    List<BoxShadow>? softShadow,
    List<BoxShadow>? glowShadow,
    Color? ringColor,
  }) {
    return AppThemeExtension(
      heroGradient: heroGradient ?? this.heroGradient,
      warmGradient: warmGradient ?? this.warmGradient,
      softShadow: softShadow ?? this.softShadow,
      glowShadow: glowShadow ?? this.glowShadow,
      ringColor: ringColor ?? this.ringColor,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      heroGradient: LinearGradient.lerp(heroGradient, other.heroGradient, t)!,
      warmGradient: LinearGradient.lerp(warmGradient, other.warmGradient, t)!,
      softShadow: BoxShadow.lerpList(softShadow, other.softShadow, t) ?? softShadow,
      glowShadow: BoxShadow.lerpList(glowShadow, other.glowShadow, t) ?? glowShadow,
      ringColor: Color.lerp(ringColor, other.ringColor, t)!,
    );
  }
}
