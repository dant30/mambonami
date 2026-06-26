// mobile/lib/blocs/theme/theme_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/cache_manager.dart';
import '../../core/constants.dart';

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
    final storedIndex = await CacheManager.instance.getInt(kThemeModeKey);
    final index = storedIndex ?? 2; // 0: light, 1: dark, 2: system
    final mode = ThemeMode.values[index.clamp(0, 2)];
    emit(ThemeState(themeMode: mode));
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    await CacheManager.instance.saveInt(kThemeModeKey, mode.index);
  }
}