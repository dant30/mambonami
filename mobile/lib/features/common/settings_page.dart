import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/theme/theme_bloc.dart';
import '../../core/constants.dart';
import '../../data/local/cache_manager.dart';
import '../../data/local/database_helper.dart';
import '../../shared/layouts/app_drawer.dart';
import '../../shared/layouts/app_navigation.dart';
import '../../shared/layouts/app_screen.dart';
import '../../shared/layouts/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_snackbar.dart';
import '../../shared/widgets/section_header.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final enabled = await CacheManager.instance.getBool(kNotificationsEnabledKey);
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled ?? true;
      _loading = false;
    });
  }

  Future<void> _saveNotifications(bool enabled) async {
    await CacheManager.instance.saveBool(kNotificationsEnabledKey, enabled);
    if (!mounted) return;
    setState(() => _notificationsEnabled = enabled);
    CustomSnackbar.showSuccess(
      context,
      enabled ? 'Notifications enabled' : 'Notifications disabled',
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final themeMode = context.watch<ThemeCubit>().state.themeMode;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavigationBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AppScreen(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Appearance',
                    subtitle: 'Choose how Mambonami looks on this device',
                  ),
                  CustomCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.system,
                          groupValue: themeMode,
                          onChanged: (mode) => themeCubit.setThemeMode(mode!),
                          title: const Text('System'),
                          subtitle: const Text('Follow device setting'),
                          secondary: const Icon(Icons.brightness_auto_outlined),
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.light,
                          groupValue: themeMode,
                          onChanged: (mode) => themeCubit.setThemeMode(mode!),
                          title: const Text('Light'),
                          secondary: const Icon(Icons.light_mode_outlined),
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.dark,
                          groupValue: themeMode,
                          onChanged: (mode) => themeCubit.setThemeMode(mode!),
                          title: const Text('Dark'),
                          secondary: const Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SectionHeader(
                    title: 'Notifications',
                    subtitle: 'Control account and order updates',
                  ),
                  CustomCard(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: SwitchListTile(
                      value: _notificationsEnabled,
                      onChanged: _saveNotifications,
                      title: const Text('Push notifications'),
                      subtitle: const Text('Delivery, order, and account alerts'),
                      secondary: const Icon(Icons.notifications_active_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SectionHeader(
                    title: 'Local Data',
                    subtitle: 'Clear cached settings and offline app data',
                  ),
                  CustomCard(
                    margin: EdgeInsets.zero,
                    child: CustomButton(
                      onPressed: () async {
                        await CacheManager.instance.clear();
                        await DatabaseHelper.instance.clearAll();
                        if (!mounted) return;
                        CustomSnackbar.showSuccess(
                          context,
                          'Local settings cleared',
                        );
                      },
                      label: 'Clear local data',
                      outlined: true,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
