// lib/features/common/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/locale/locale_cubit.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../core/constants.dart';
import '../../config/route_paths.dart';
import '../../data/local/cache_manager.dart';
import '../../data/local/database_helper.dart';
import '../../shared/layouts/app_drawer.dart';
import '../../shared/layouts/app_navigation.dart';
import '../../shared/layouts/app_screen.dart';
import '../../shared/layouts/custom_app_bar.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_dialog.dart';
import '../../shared/widgets/custom_snackbar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/info_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _orderUpdatesEnabled = true;
  String _notificationPermission = 'Unknown';
  bool _loading = true;
  bool _locationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final notificationsEnabled =
        await CacheManager.instance.getBool(kNotificationsEnabledKey);
    final orderUpdatesEnabled =
        await CacheManager.instance.getBool(kOrderUpdatesEnabledKey);
    final locationEnabled =
        await CacheManager.instance.getBool('location_enabled') ?? true;

    // Load Firebase notification permission status
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      _notificationPermission = settings.authorizationStatus.name;
    } catch (_) {
      _notificationPermission = 'unknown';
    }

    if (!mounted) return;
    setState(() {
      _notificationsEnabled = notificationsEnabled ?? true;
      _orderUpdatesEnabled = orderUpdatesEnabled ?? true;
      _locationEnabled = locationEnabled;
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

  Future<void> _requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
    if (!mounted) return;
    setState(() => _notificationPermission = settings.authorizationStatus.name);
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      CustomSnackbar.showSuccess(context, 'Notification permission granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      CustomSnackbar.showError(context, 'Notification permission denied');
    }
  }

  Future<void> _saveOrderUpdates(bool enabled) async {
    await CacheManager.instance.saveBool(kOrderUpdatesEnabledKey, enabled);
    if (!mounted) return;
    setState(() => _orderUpdatesEnabled = enabled);
    CustomSnackbar.showSuccess(
      context,
      enabled ? 'Order updates enabled' : 'Order updates disabled',
    );
  }

  void _showLanguageDialog() {
    final locale = context.read<LocaleCubit>().state.locale;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              value: const Locale('en'),
              groupValue: locale,
              title: const Text('English'),
              onChanged: (newLocale) {
                if (newLocale != null) {
                  context.read<LocaleCubit>().setLocale(newLocale);
                  Navigator.pop(ctx);
                }
              },
            ),
            RadioListTile<Locale>(
              value: const Locale('sw'),
              groupValue: locale,
              title: const Text('Kiswahili'),
              onChanged: (newLocale) {
                if (newLocale != null) {
                  context.read<LocaleCubit>().setLocale(newLocale);
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    CustomDialog.showConfirmWithAction(
      context,
      'Delete Account',
      'This action cannot be undone. Are you sure you want to delete your account?',
      confirmText: 'Delete',
      onConfirm: () async {
        // TODO: Implement account deletion
        CustomSnackbar.showInfo(context, 'Account deletion not implemented yet.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeCubit>().state.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        showNotificationAction: false,
        showBackButton: true,
        fallbackRoute: RoutePaths.profile,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavigationBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AppScreen(
              scrollable: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ListView(
                children: [
                  // ─── Account Section ──────────────────────────────────────
                  const _SectionLabel('Account'),
                  const SizedBox(height: 8),
                  _buildAccountTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Name, phone, photo',
                    onTap: () => context.go(RoutePaths.profile),
                  ),
                  _buildAccountTile(
                    icon: Icons.lock_reset_outlined,
                    title: 'Change Password',
                    subtitle: 'Update security credentials',
                    onTap: () {
                      CustomSnackbar.showInfo(
                        context,
                        'Change password screen coming soon',
                      );
                    },
                  ),
                  _buildAccountTile(
                    icon: Icons.link_outlined,
                    title: 'Linked Accounts',
                    subtitle: 'Google, M-Pesa',
                    onTap: () {
                      CustomSnackbar.showInfo(
                        context,
                        'Linked accounts coming soon',
                      );
                    },
                  ),
                  _buildAccountTile(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'English / Kiswahili',
                    onTap: _showLanguageDialog,
                  ),
                  const SizedBox(height: 24),

                  // ─── Preferences Section ──────────────────────────────────
                  const _SectionLabel('Preferences'),
                  const SizedBox(height: 8),
                  _buildPreferenceSwitch(
                    icon: Icons.notifications_active_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Orders, payments, updates',
                    value: _notificationsEnabled,
                    onChanged: _saveNotifications,
                  ),
                  _buildPreferenceSwitch(
                    icon: Icons.track_changes_outlined,
                    title: 'Order Updates',
                    subtitle: 'Track order progress and status changes',
                    value: _orderUpdatesEnabled,
                    onChanged: _saveOrderUpdates,
                  ),
                  _buildPreferenceSwitch(
                    icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Switch app appearance',
                    value: isDark,
                    onChanged: (value) {
                      context.read<ThemeCubit>().setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                  _buildPreferenceSwitch(
                    icon: Icons.location_on_outlined,
                    title: 'Location Access',
                    subtitle: 'For GPS and delivery',
                    value: _locationEnabled,
                    onChanged: (value) async {
                      if (value) {
                        final status = await Permission.location.request();
                        if (status.isGranted) {
                          setState(() => _locationEnabled = true);
                        }
                      } else {
                        await Permission.location.shouldShowRequestRationale;
                        // In practice, you would open app settings
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // ─── Privacy & Legal Section ──────────────────────────────
                  const _SectionLabel('Privacy & Legal'),
                  const SizedBox(height: 8),
                  _buildLegalTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () {
                      CustomSnackbar.showInfo(context, 'Privacy policy coming soon');
                    },
                  ),
                  _buildLegalTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'View terms and conditions',
                    onTap: () {
                      CustomSnackbar.showInfo(context, 'Terms of service coming soon');
                    },
                  ),
                  _buildLegalTile(
                    icon: Icons.delete_outline,
                    title: 'Delete Account',
                    subtitle: 'Permanently remove your account',
                    destructive: true,
                    onTap: _confirmDeleteAccount,
                  ),
                  const SizedBox(height: 8),
                  // ── Notification permission helper ──────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'App notification permission',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _requestNotificationPermission,
                          child: Text(
                            _notificationPermission,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ─── Clear Local Data ──────────────────────────────────────
                  CustomCard(
                    margin: EdgeInsets.zero,
                    child: CustomButton(
                      onPressed: () async {
                        final confirmed = await CustomDialog.showConfirm(
                          context,
                          'Clear Local Data',
                          'This will clear all cached settings and offline data. Are you sure?',
                        );
                        if (confirmed == true) {
                          await CacheManager.instance.clear();
                          await DatabaseHelper.instance.clearAll();
                          if (!mounted) return;
                          CustomSnackbar.showSuccess(
                            context,
                            'Local settings cleared',
                          );
                        }
                      },
                      label: 'Clear Local Data',
                      outlined: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildAccountTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: CustomCard(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
            ),
          ),
          onTap: () => onChanged(!value),
        ),
      ),
    );
  }

  Widget _buildLegalTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool destructive = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final color = destructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: destructive
                  ? theme.colorScheme.error.withOpacity(0.12)
                  : theme.colorScheme.primary.withOpacity(0.12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: color.withOpacity(0.5),
            size: 18,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 12),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}