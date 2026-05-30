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
      icon: const Icon(Icons.brightness_6),
      onSelected: (mode) => context.read<ThemeCubit>().setThemeMode(mode),
      itemBuilder: (context) => [
        const PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
        const PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
        const PopupMenuItem(value: ThemeMode.system, child: Text('System')),
      ],
    );
  }
}