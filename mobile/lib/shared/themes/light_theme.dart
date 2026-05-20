// mobile/lib/shared/themes/light_theme.dart
import 'package:flutter/material.dart';

const Color primaryGreen = Color(0xFF2E7D32);
const Color primaryLight = Color(0xFF60AD5E);
const Color primaryDark = Color(0xFF005005);
const Color accentOrange = Color(0xFFFF9800);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color surfaceLight = Colors.white;
const Color errorLight = Color(0xFFD32F2F);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryGreen,
  scaffoldBackgroundColor: backgroundLight,
  colorScheme: const ColorScheme.light(
    primary: primaryGreen,
    secondary: accentOrange,
    error: errorLight,
    surface: surfaceLight,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    filled: true,
    fillColor: surfaceLight,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: primaryGreen),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(8),
  ),
  fontFamily: 'Poppins',
);