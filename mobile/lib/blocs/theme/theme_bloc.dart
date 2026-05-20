import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme state
class ThemeState {
  final ThemeMode themeMode;
  ThemeState({required this.themeMode});
}

// Theme cubit (simpler than bloc for single event)
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(themeMode: ThemeMode.system)) {
    _loadTheme();
  }

  void toggleTheme(bool isDark) {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(mode);
    emit(ThemeState(themeMode: mode));
  }

  void setThemeMode(ThemeMode mode) {
    _saveTheme(mode);
    emit(ThemeState(themeMode: mode));
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_mode') ?? 2; // 0: light, 1: dark, 2: system
    final mode = ThemeMode.values[index.clamp(0, 2)];
    emit(ThemeState(themeMode: mode));
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }
}