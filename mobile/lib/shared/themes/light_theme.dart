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
    surface: AppColors.cardLight,
    onSurface: AppColors.foregroundLight,
    surfaceContainerHighest: AppColors.surfaceHighLight,
    outline: AppColors.outlineLight,
    error: AppColors.destructiveLight,
    onError: AppColors.destructiveForegroundLight,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundLight,
    foregroundColor: AppColors.foregroundLight,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.outlineLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.outlineLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.4),
    ),
    filled: true,
    fillColor: AppColors.inputLight,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.primaryForegroundLight,
      elevation: 0,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.primaryLight),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AppColors.outlineLight),
    ),
    margin: EdgeInsets.zero,
    color: AppColors.cardLight,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.cardLight,
    indicatorColor: AppColors.primaryLight.withValues(alpha: 0.14),
    elevation: 0,
    height: 68,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        fontSize: 12,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w800
            : FontWeight.w600,
        color: states.contains(WidgetState.selected)
            ? AppColors.primaryLight
            : AppColors.foregroundLight.withValues(alpha: 0.62),
      ),
    ),
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        size: 23,
        color: states.contains(WidgetState.selected)
            ? AppColors.primaryLight
            : AppColors.foregroundLight.withValues(alpha: 0.58),
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.outlineLight,
    thickness: 1,
    space: 1,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.foregroundLight,
    contentPadding: EdgeInsets.symmetric(horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceHighLight,
    selectedColor: AppColors.primaryLight.withValues(alpha: 0.16),
    side: const BorderSide(color: AppColors.outlineLight),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
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
