// mobile/lib/shared/themes/dark_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_gradients.dart';
import 'app_shadows.dart';
import 'app_theme_extension.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryDark,
    onPrimary: AppColors.primaryForegroundDark,
    secondary: AppColors.secondaryDark,
    onSecondary: AppColors.secondaryForegroundDark,
    primaryContainer: AppColors.primaryDark.withValues(alpha: 0.16),
    onPrimaryContainer: AppColors.primaryDark,
    secondaryContainer: AppColors.secondaryDark.withValues(alpha: 0.16),
    onSecondaryContainer: AppColors.secondaryForegroundDark,
    surface: AppColors.cardDark,
    onSurface: AppColors.foregroundDark,
    onSurfaceVariant: AppColors.foregroundDark.withValues(alpha: 0.68),
    surfaceContainerHighest: AppColors.surfaceHighDark,
    outline: AppColors.outlineDark,
    error: AppColors.destructiveDark,
    onError: AppColors.destructiveForegroundDark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundDark,
    foregroundColor: AppColors.foregroundDark,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.outlineDark),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.outlineDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.4),
    ),
    filled: true,
    fillColor: AppColors.inputDark,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    labelStyle: TextStyle(
      color: AppColors.foregroundDark.withValues(alpha: 0.72),
    ),
    hintStyle: TextStyle(
      color: AppColors.foregroundDark.withValues(alpha: 0.48),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.primaryForegroundDark,
      elevation: 0,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.primaryForegroundDark,
      minimumSize: const Size(48, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AppColors.outlineDark),
    ),
    margin: EdgeInsets.zero,
    color: AppColors.cardDark,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.cardDark,
    indicatorColor: AppColors.primaryDark.withValues(alpha: 0.16),
    elevation: 0,
    height: 68,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        fontSize: 12,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w800
            : FontWeight.w600,
        color: states.contains(WidgetState.selected)
            ? AppColors.primaryDark
            : AppColors.foregroundDark.withValues(alpha: 0.62),
      ),
    ),
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        size: 23,
        color: states.contains(WidgetState.selected)
            ? AppColors.primaryDark
            : AppColors.foregroundDark.withValues(alpha: 0.58),
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.outlineDark,
    thickness: 1,
    space: 1,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: AppColors.foregroundDark,
    contentPadding: EdgeInsets.symmetric(horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceHighDark,
    selectedColor: AppColors.primaryDark.withValues(alpha: 0.16),
    side: const BorderSide(color: AppColors.outlineDark),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
  ),
  extensions: <ThemeExtension<dynamic>>[
    AppThemeExtension(
      heroGradient: AppGradients.hero,
      warmGradient: AppGradients.warm,
      softShadow: AppShadows.soft,
      glowShadow: AppShadows.glow,
      ringColor: AppColors.ringDark,
    ),
  ],
);
