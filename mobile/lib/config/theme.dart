// mobile/lib/config/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/themes/light_theme.dart';
import '../shared/themes/dark_theme.dart';

export '../shared/themes/light_theme.dart';
export '../shared/themes/dark_theme.dart';
export '../blocs/theme/theme_bloc.dart';

/// Build a ThemeData that uses Google Fonts and Material 3.
ThemeData buildTheme(ThemeData themeData) {
  return themeData.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(themeData.textTheme),
    primaryTextTheme: GoogleFonts.poppinsTextTheme(themeData.primaryTextTheme),
    useMaterial3: true,
  );
}

ThemeData getLightTheme() => buildTheme(lightTheme);
ThemeData getDarkTheme() => buildTheme(darkTheme);

/// Get the appropriate ThemeData based on brightness and theme mode.
ThemeData getThemeData(Brightness brightness, ThemeMode mode) {
  if (mode == ThemeMode.light) return getLightTheme();
  if (mode == ThemeMode.dark) return getDarkTheme();
  // System mode: use brightness from MediaQuery
  return brightness == Brightness.light ? getLightTheme() : getDarkTheme();
}