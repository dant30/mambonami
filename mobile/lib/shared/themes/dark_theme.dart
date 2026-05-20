// mobile/lib/shared//themes/dark_theme.dart
import 'package:flutter/material.dart';

const Color primaryGreenDark = Color(0xFF81C784);
const Color accentOrangeDark = Color(0xFFFFB74D);
const Color backgroundDark = Color(0xFF121212);
const Color surfaceDark = Color(0xFF1E1E1E);
const Color errorDark = Color(0xFFEF5350);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryGreenDark,
  scaffoldBackgroundColor: backgroundDark,
  colorScheme: const ColorScheme.dark(
    primary: primaryGreenDark,
    secondary: accentOrangeDark,
    error: errorDark,
    surface: surfaceDark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: surfaceDark,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    filled: true,
    fillColor: surfaceDark,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreenDark,
      foregroundColor: Colors.black,
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: primaryGreenDark),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(8),
    color: surfaceDark,
  ),
  fontFamily: 'Poppins',
);