// mobile/lib/shared/themes/light_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_gradients.dart';
import 'app_shadows.dart';
import 'app_theme_extension.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Poppins',
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryLight,
    onPrimary: AppColors.primaryForegroundLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.secondaryForegroundLight,
    primaryContainer: AppColors.primaryLight.withValues(alpha: 0.12),
    onPrimaryContainer: AppColors.primaryLight,
    secondaryContainer: AppColors.secondaryLight.withValues(alpha: 0.14),
    onSecondaryContainer: AppColors.secondaryForegroundLight,
    surface: AppColors.cardLight,
    onSurface: AppColors.foregroundLight,
    onSurfaceVariant: AppColors.foregroundLight.withValues(alpha: 0.66),
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
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.foregroundLight,
      fontFamily: 'Poppins',
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.outlineLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.outlineLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.4),
    ),
    filled: true,
    fillColor: AppColors.inputLight,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    labelStyle: TextStyle(
      color: AppColors.foregroundLight.withValues(alpha: 0.74),
      fontWeight: FontWeight.w600,
    ),
    hintStyle: TextStyle(
      color: AppColors.foregroundLight.withValues(alpha: 0.48),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.primaryForegroundLight,
      elevation: 0,
      minimumSize: const Size(double.infinity, 52),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.primaryForegroundLight,
      minimumSize: const Size(48, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      side: const BorderSide(color: AppColors.outlineLight, width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
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
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceHighLight,
    selectedColor: AppColors.primaryLight.withValues(alpha: 0.16),
    side: const BorderSide(color: AppColors.outlineLight),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
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
