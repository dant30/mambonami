// mobile/lib/features/common/support_page.dart
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
import '../../shared/themes/app_radius.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_dialog.dart';
import '../../shared/widgets/custom_snackbar.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/info_tile.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  bool _notificationsEnabled = true;
  bool _orderUpdatesEnabled = true;
  bool _darkMode = false;
  bool _locationEnabled = true; // placeholder
  String _notificationPermission = 'Unknown';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final notificationsEnabled = await CacheManager.instance.getBool(kNotificationsEnabledKey);
    final orderUpdatesEnabled = await CacheManager.instance.getBool(kOrderUpdatesEnabledKey);
    final darkMode = await CacheManager.instance.getBool('dark_mode') ?? false;
    final locationEnabled = await CacheManager.instance.getBool('location_enabled') ?? true;

    // load firebase notification permission status
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
      _darkMode = darkMode;
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

  Future<void> _saveOrderUpdates(bool enabled) async {
    await CacheManager.instance.saveBool(kOrderUpdatesEnabledKey, enabled);
    if (!mounted) return;
    setState(() => _orderUpdatesEnabled = enabled);
    CustomSnackbar.showSuccess(
      context,
      enabled ? 'Order updates enabled' : 'Order updates disabled',
    );
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _darkMode = value);
    await CacheManager.instance.saveBool('dark_mode', value);
    context.read<ThemeCubit>().setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _toggleLocation(bool value) async {
    setState(() => _locationEnabled = value);
    await CacheManager.instance.saveBool('location_enabled', value);
    if (value) {
      await Permission.location.request();
    } else {
      // Show rationale or open settings
      CustomSnackbar.showInfo(context, 'You can disable location in system settings.');
    }
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
    final isDark = theme.brightness == Brightness.dark;

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
                  const SectionHeader(
                    title: 'Account',
                    subtitle: 'Manage your profile and security',
                  ),
                  const SizedBox(height: 12),
                  InfoTile(
                    title: 'Edit Profile',
                    subtitle: 'Name, phone, photo',
                    icon: Icons.person_outline,
                    onTap: () => context.go(RoutePaths.profile),
                  ),
                  const SizedBox(height: 8),
                  InfoTile(
                    title: 'Change Password',
                    subtitle: 'Update security credentials',
                    icon: Icons.lock_reset_outlined,
                    onTap: () {
                      // TODO: Navigate to change password page
                      CustomSnackbar.showInfo(context, 'Change password screen coming soon');
                    },
                  ),
                  const SizedBox(height: 8),
                  InfoTile(
                    title: 'Linked Accounts',
                    subtitle: 'Google, M-Pesa',
                    icon: Icons.link_outlined,
                    onTap: () {
                      // TODO: Show linked accounts
                      CustomSnackbar.showInfo(context, 'Linked accounts coming soon');
                    },
                  ),
                  const SizedBox(height: 8),
                  InfoTile(
                    title: 'Language',
                    subtitle: 'English / Kiswahili',
                    icon: Icons.language_outlined,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onTap: _showLanguageDialog,
                  ),
                  const SizedBox(height: 24),

                  // ─── Preferences Section ──────────────────────────────────
                  const SectionHeader(
                    title: 'Preferences',
                    subtitle: 'Customize your experience',
                  ),
                  const SizedBox(height: 12),
                  CustomCard(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          context,
                          title: 'Push Notifications',
                          subtitle: 'Orders, payments, updates',
                          value: _notificationsEnabled,
                          onChanged: _saveNotifications,
                          icon: Icons.notifications_active_outlined,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          context,
                          title: 'Order Updates',
                          subtitle: 'Track order progress and status changes',
                          value: _orderUpdatesEnabled,
                          onChanged: _saveOrderUpdates,
                          icon: Icons.track_changes_outlined,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          context,
                          title: 'Dark Mode',
                          subtitle: 'Switch app appearance',
                          value: _darkMode,
                          onChanged: _toggleDarkMode,
                          icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          context,
                          title: 'Location Access',
                          subtitle: 'For GPS and delivery',
                          value: _locationEnabled,
                          onChanged: _toggleLocation,
                          icon: Icons.location_on_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Privacy & Legal Section ──────────────────────────────
                  const SectionHeader(
                    title: 'Privacy & Legal',
                    subtitle: 'Manage your data and legal agreements',
                  ),
                  const SizedBox(height: 12),
                  InfoTile(
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {
                      // TODO: Open privacy policy
                      CustomSnackbar.showInfo(context, 'Privacy policy coming soon');
                    },
                  ),
                  const SizedBox(height: 8),
                  InfoTile(
                    title: 'Terms of Service',
                    subtitle: 'View terms and conditions',
                    icon: Icons.description_outlined,
                    onTap: () {
                      // TODO: Open terms of service
                      CustomSnackbar.showInfo(context, 'Terms of service coming soon');
                    },
                  ),
                  const SizedBox(height: 8),
                  InfoTile(
                    title: 'Delete Account',
                    subtitle: 'Permanently remove your account',
                    icon: Icons.delete_outline,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.error,
                    ),
                    onTap: _confirmDeleteAccount,
                  ),
                  const SizedBox(height: 8),
                  InfoTile(
                    title: 'App notification permission',
                    subtitle: _notificationPermission,
                    icon: Icons.notifications_none_outlined,
                    trailing: TextButton(
                      onPressed: _requestNotificationPermission,
                      child: const Text('Request'),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ─── Clear Data ──────────────────────────────────────────
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

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.12),
          borderRadius: AppRadius.small,
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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
    );
  }
}

// If you don't have InfoTile yet, uncomment this fallback:
/*
class InfoTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;

  const InfoTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            color: textColor ?? theme.colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
      ),
    );
  }
}
*/