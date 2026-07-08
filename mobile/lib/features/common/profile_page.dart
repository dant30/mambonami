// lib/features/common/profile_page.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../config/route_paths.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/layouts/app_navigation.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_gradients.dart';
import '../../shared/themes/app_radius.dart';
import '../../shared/utils/form_validators.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_image_picker.dart';
import '../../shared/widgets/custom_snackbar.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/section_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ── Controllers ───────────────────────────────────────────────────────────
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  bool _isDeletingAccount = false;
  bool _isEditing = false;

  String? _profileImageUrl;
  File? _selectedAvatarFile;
  String? _firstName;
  String? _lastName;
  String? _username;
  String? _role;
  String? _location;
  Map<String, dynamic>? _transportProfile;
  Map<String, dynamic>? _farmProfile;

  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Data loading ─────────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _authRepository.getProfile();
      _usernameController.text = profile['username']?.toString() ?? '';
      _emailController.text = profile['email']?.toString() ?? '';
      _firstNameController.text = profile['first_name']?.toString() ?? '';
      _lastNameController.text = profile['last_name']?.toString() ?? '';
      _phoneController.text = FormValidators.formatPhone(
        profile['phone']?.toString() ??
            (context.read<AuthBloc>().state is AuthAuthenticated
                ? (context.read<AuthBloc>().state as AuthAuthenticated).phone
                : ''),
      );
      _role = profile['role']?.toString();
      _transportProfile = profile['transport_profile'] is Map<String, dynamic>
          ? profile['transport_profile'] as Map<String, dynamic>
          : null;
      _farmProfile = profile['farm_profile'] is Map<String, dynamic>
          ? profile['farm_profile'] as Map<String, dynamic>
          : null;

      setState(() {
        _profileImageUrl = profile['profile_image']?.toString();
        _selectedAvatarFile = null;
        _firstName = profile['first_name']?.toString();
        _lastName = profile['last_name']?.toString();
        _username = profile['username']?.toString();
        _location = profile['location']?.toString();
      });
    } catch (e) {
      CustomSnackbar.showError(context, 'Failed to load profile: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Save profile ──────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final api = GetIt.I<ApiClient>();
      final payload = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
      };
      await api.dio.patch(kProfileEndpoint, data: payload);
      CustomSnackbar.showSuccess(context, 'Profile updated');
      await _loadProfile(); // refresh data
      setState(() => _isEditing = false);
    } catch (e) {
      CustomSnackbar.showError(context, 'Update failed: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ── Avatar picker ────────────────────────────────────────────────────────
  Future<void> _pickAvatarImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final file = await CustomImagePicker.pickImage(source: source);
    if (file == null) return;

    setState(() => _isSaving = true);
    try {
      final api = GetIt.I<ApiClient>();
      final formData = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });
      await api.dio.patch(kProfileEndpoint, data: formData);
      setState(() {
        _selectedAvatarFile = file;
      });
      CustomSnackbar.showSuccess(context, 'Profile photo updated');
      await _loadProfile();
    } catch (e) {
      CustomSnackbar.showError(context, 'Photo upload failed: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ── Password change ──────────────────────────────────────────────────────
  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      CustomSnackbar.showError(context, 'Please fill all password fields.');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      CustomSnackbar.showError(context, 'Passwords do not match.');
      return;
    }
    setState(() => _isChangingPassword = true);
    try {
      await _authRepository.changePassword(
        _oldPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );
      CustomSnackbar.showSuccess(context, 'Password updated successfully.');
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      CustomSnackbar.showError(context, 'Password change failed: ${e.toString()}');
    } finally {
      setState(() => _isChangingPassword = false);
    }
  }

  // ── Delete account ──────────────────────────────────────────────────────
  Future<void> _deleteAccount() async {
    setState(() => _isDeletingAccount = true);
    try {
      await _authRepository.deleteAccount();
      context.read<AuthBloc>().add(LogoutEvent());
    } catch (e) {
      CustomSnackbar.showError(context, 'Failed to delete account: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. Do you want to delete your account?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteAccount();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String get _displayName {
    final full = '${_firstName ?? ''} ${_lastName ?? ''}'.trim();
    return full.isNotEmpty ? full : (_username ?? 'User');
  }

  String get _displayRole {
    if (_role == null) return '';
    return _role!.replaceAll('_', ' ').toUpperCase();
  }

  List<_StatItem> get _stats {
    if (_role == 'farmer') {
      final earnings = _farmProfile?['total_sales']?.toString() ?? '0';
      final rating = _farmProfile?['rating']?.toString() ?? '4.8 ★';
      final orders = _farmProfile?['total_orders']?.toString() ?? '48';
      return [
        _StatItem(label: 'Earnings', value: 'KES $earnings'),
        _StatItem(label: 'Rating', value: rating),
        _StatItem(label: 'Orders', value: orders),
      ];
    } else if (_role == 'transport_provider') {
      final deliveries = _transportProfile?['total_deliveries']?.toString() ?? '0';
      final rating = _transportProfile?['rating']?.toString() ?? '4.8 ★';
      final trips = _transportProfile?['total_trips']?.toString() ?? '0';
      return [
        _StatItem(label: 'Deliveries', value: deliveries),
        _StatItem(label: 'Rating', value: rating),
        _StatItem(label: 'Trips', value: trips),
      ];
    } else {
      return [
        _StatItem(label: 'Orders', value: '0'),
        _StatItem(label: 'Rating', value: '4.5 ★'),
        _StatItem(label: 'Items', value: '0'),
      ];
    }
  }

  List<_VerificationItem> get _verifications {
    return [
      _VerificationItem(label: 'Phone Number', verified: true),
      _VerificationItem(label: 'National ID', verified: true),
      _VerificationItem(label: 'Cooperative Endorsement', verified: _farmProfile?['coop_verified'] == true),
      _VerificationItem(label: 'Farm GPS Location', verified: _farmProfile?['farm_gps'] != null && _farmProfile!['farm_gps'].isNotEmpty),
      _VerificationItem(label: 'Bank Account', verified: false),
    ];
  }

  // ─── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── Gradient Header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
            decoration: const BoxDecoration(gradient: AppGradients.hero),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isEditing ? Icons.close : Icons.edit_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      onPressed: () => setState(() => _isEditing = !_isEditing),
                      tooltip: _isEditing ? 'Cancel editing' : 'Edit profile',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // ─── Avatar ───────────────────────────────────────────────────
                GestureDetector(
                  onTap: _isEditing ? _pickAvatarImage : null,
                  child: Stack(
                    children: [
                      Avatar(
                        imageUrl: _profileImageUrl,
                        imageFile: _selectedAvatarFile,
                        firstName: _firstName,
                        lastName: _lastName,
                        username: _username,
                        size: 84,
                        backgroundColor: Colors.white24,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _phoneController.text,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '✓ Verified ${_displayRole.isNotEmpty ? _displayRole : 'User'}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Body ──────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Stats row ──────────────────────────────────────────────
                  Row(
                    children: _stats.map((stat) {
                      return Expanded(
                        child: _StatTile(value: stat.value, label: stat.label),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ─── Verification ──────────────────────────────────────────
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verification',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._verifications.map((v) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  v.label,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.dark,
                                  ),
                                ),
                              ),
                              if (v.verified)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '✓ Verified',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.warning,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    '+ Add',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ─── Menu items ────────────────────────────────────────────
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet & Payouts',
                    subtitle: 'M-Pesa · Bank',
                    onTap: () {
                      // TODO: Navigate to wallet page
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    subtitle: 'Order, payment alerts',
                    onTap: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    subtitle: null,
                    onTap: () => context.go(RoutePaths.settings),
                  ),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    subtitle: null,
                    onTap: () => context.go(RoutePaths.support),
                  ),
                  const SizedBox(height: 24),

                  // ─── Logout ──────────────────────────────────────────────────
                  GestureDetector(
                    onTap: _confirmLogout,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Edit Form (visible when editing) ──────────────────────
                  if (_isEditing) ...[
                    const Divider(height: 32),
                    const SectionHeader(
                      title: 'Personal Information',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    const SectionHeader(
                      title: 'Account Settings',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _usernameController,
                      label: 'Username',
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        return v.contains('@') ? null : 'Enter valid email';
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone',
                      keyboardType: TextInputType.phone,
                      enabled: false,
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Change Password',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _oldPasswordController,
                      label: 'Current password',
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _newPasswordController,
                      label: 'New password',
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm new password',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      onPressed: _isChangingPassword ? null : _changePassword,
                      isLoading: _isChangingPassword,
                      label: 'Update password',
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(
                      title: 'Actions',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      onPressed: _saveProfile,
                      isLoading: _isSaving,
                      label: 'Save Changes',
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      onPressed: _confirmDeleteAccount,
                      isLoading: _isDeletingAccount,
                      label: 'Delete account',
                      color: Theme.of(context).colorScheme.error,
                      outlined: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  // ─── Menu item helper ────────────────────────────────────────────────────
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return CustomCard(
      margin: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: AppRadius.medium,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

// ─── Helper classes ──────────────────────────────────────────────────────────

class _StatItem {
  final String label;
  final String value;
  _StatItem({required this.label, required this.value});
}

class _VerificationItem {
  final String label;
  final bool verified;
  _VerificationItem({required this.label, required this.verified});
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: CustomCard(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
}