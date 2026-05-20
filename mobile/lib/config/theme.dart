// mobile/lib/config/theme.dart
import 'package:flutter/material.dart';
import '../shared/themes/light_theme.dart';
import '../shared/themes/dark_theme.dart';

export '../shared/themes/light_theme.dart';
export '../shared/themes/dark_theme.dart';
export '../blocs/theme/theme_bloc.dart';

/// Get the appropriate ThemeData based on brightness and theme mode.
ThemeData getThemeData(Brightness brightness, ThemeMode mode) {
  if (mode == ThemeMode.light) return lightTheme;
  if (mode == ThemeMode.dark) return darkTheme;
  // System mode: use brightness from MediaQuery
  return brightness == Brightness.light ? lightTheme : darkTheme;
}