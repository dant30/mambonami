// lib/shared/widgets/theme_switcher.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    return PopupMenuButton<ThemeMode>(
      tooltip: 'Theme',
      initialValue: themeState.themeMode,
      icon: Icon(
        themeState.themeMode == ThemeMode.dark
            ? Icons.dark_mode_outlined
            : themeState.themeMode == ThemeMode.light
                ? Icons.light_mode_outlined
                : Icons.brightness_auto_outlined,
      ),
      onSelected: (mode) => context.read<ThemeCubit>().setThemeMode(mode),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [Icon(Icons.light_mode), SizedBox(width: 8), Text('Light')],
          ),
        ),
        const PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [Icon(Icons.dark_mode), SizedBox(width: 8), Text('Dark')],
          ),
        ),
        const PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [Icon(Icons.settings), SizedBox(width: 8), Text('System')],
          ),
        ),
      ],
    );
  }
}
