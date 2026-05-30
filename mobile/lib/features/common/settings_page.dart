import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/theme/theme_bloc.dart';
import '../../shared/layouts/app_drawer.dart';
import '../../shared/layouts/app_navigation.dart';
import '../../shared/layouts/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_snackbar.dart';

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
		final prefs = await SharedPreferences.getInstance();
		setState(() {
			_notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
			_loading = false;
		});
	}

	Future<void> _saveNotifications(bool enabled) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setBool('notifications_enabled', enabled);
		setState(() => _notificationsEnabled = enabled);
		CustomSnackbar.showSuccess(context, enabled ? 'Notifications enabled' : 'Notifications disabled');
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
					: ListView(
							padding: EdgeInsets.fromLTRB(
								16,
								16,
								16,
								16 + MediaQuery.of(context).padding.bottom,
							),
							children: [
								const Text('Appearance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
								const SizedBox(height: 8),
								Row(
									children: [
										Expanded(child: Text('Theme: ${_themeLabel(themeMode)}')),
										PopupMenuButton<ThemeMode>(
											onSelected: (mode) => themeCubit.setThemeMode(mode),
											itemBuilder: (_) => const [
												PopupMenuItem(value: ThemeMode.system, child: Text('System')),
												PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
												PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
											],
											child: const Icon(Icons.chevron_right),
										),
									],
								),
								const SizedBox(height: 20),
								const Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
								const SizedBox(height: 8),
								SwitchListTile(
									value: _notificationsEnabled,
									onChanged: (v) => _saveNotifications(v),
									title: const Text('Enable push notifications'),
								),
								const SizedBox(height: 24),
								CustomButton(
									onPressed: () async {
										// Example: clear cached app data
										final prefs = await SharedPreferences.getInstance();
										await prefs.clear();
										CustomSnackbar.showSuccess(context, 'Local settings cleared');
									},
									label: 'Clear local data',
								),
							],
						),
		);
	}

	String _themeLabel(ThemeMode mode) {
		switch (mode) {
			case ThemeMode.light:
				return 'Light';
			case ThemeMode.dark:
				return 'Dark';
			default:
				return 'System';
		}
	}
}

