// mobile/lib/shared/themes/light_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_gradients.dart';
import 'app_shadows.dart';
import 'app_theme_extension.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryLight,
    onPrimary: AppColors.primaryForegroundLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.secondaryForegroundLight,
    background: AppColors.backgroundLight,
    onBackground: AppColors.foregroundLight,
    surface: AppColors.cardLight,
    onSurface: AppColors.foregroundLight,
    error: AppColors.destructiveLight,
    onError: AppColors.destructiveForegroundLight,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: AppColors.primaryForegroundLight,
    elevation: 2,
    centerTitle: true,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    filled: true,
    fillColor: AppColors.inputLight,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.primaryForegroundLight,
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.primaryLight),
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(8),
    color: AppColors.cardLight,
  ),
  extensions: <ThemeExtension<dynamic>>[
    AppThemeExtension(
      heroGradient: AppGradients.hero,
      warmGradient: AppGradients.warm,
      softShadow: AppShadows.soft,
      glowShadow: AppShadows.glow,
      ringColor: AppColors.ringLight,
    ),
  ],
);