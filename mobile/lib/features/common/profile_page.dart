// mobile/lib/features/common/profile_page.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/constants.dart';
import '../../core/api_client.dart';
import '../../shared/layouts/custom_app_bar.dart';
import '../../shared/layouts/app_drawer.dart';
import '../../shared/layouts/app_navigation.dart';
import '../../shared/layouts/app_screen.dart';
import '../../shared/utils/form_validators.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_image_picker.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_snackbar.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_gradients.dart';
import '../../shared/themes/app_radius.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _isChangingPassword = false;
  bool _isDeletingAccount = false;
  String? _profileImageUrl;
  File? _selectedAvatarFile;
  String? _firstName;
  String? _lastName;
  String? _username;
  String? _role;
  String? _location;
  Map<String, dynamic>? _transportProfile;
  Map<String, dynamic>? _farmProfile;
  bool _isEditing = false;

  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
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

      final fullName = [profile['first_name']?.toString(), profile['last_name']?.toString()]
          .where((value) => value != null && value.isNotEmpty)
          .join(' ')
          .trim();
      if (fullName.isNotEmpty) {
        _firstNameController.text = profile['first_name']?.toString() ?? '';
        _lastNameController.text = profile['last_name']?.toString() ?? '';
      }

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
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
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
      context.read<AuthBloc>().add(CheckAuthStatusEvent());
    } catch (e) {
      CustomSnackbar.showError(context, 'Update failed: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = '${_firstName ?? ''} ${_lastName ?? ''}'.trim();
    final displayRole = _role != null ? _role!.replaceAll('_', ' ').toUpperCase() : '';

    // Build stats based on role
    List<_StatItem> stats = [];
    if (_role == 'farmer') {
      final earnings = _farmProfile?['total_sales']?.toString() ?? '0';
      final rating = _farmProfile?['rating']?.toString() ?? '4.8 ★';
      final orders = _farmProfile?['total_orders']?.toString() ?? '48';
      stats = [
        _StatItem(label: 'Earnings', value: 'KES $earnings'),
        _StatItem(label: 'Rating', value: rating),
        _StatItem(label: 'Orders', value: orders),
      ];
    } else if (_role == 'transport_provider') {
      final deliveries = _transportProfile?['total_deliveries']?.toString() ?? '0';
      final rating = _transportProfile?['rating']?.toString() ?? '4.8 ★';
      final trips = _transportProfile?['total_trips']?.toString() ?? '0';
      stats = [
        _StatItem(label: 'Deliveries', value: deliveries),
        _StatItem(label: 'Rating', value: rating),
        _StatItem(label: 'Trips', value: trips),
      ];
    } else if (_role == 'buyer' || _role == 'retailer') {
      final orders = '0'; // TODO: fetch from API
      final rating = '4.5 ★';
      final items = '0';
      stats = [
        _StatItem(label: 'Orders', value: orders),
        _StatItem(label: 'Rating', value: rating),
        _StatItem(label: 'Items', value: items),
      ];
    }

    // Verification statuses
    final verifications = [
      _VerificationItem(label: 'Phone Number', verified: true),
      _VerificationItem(label: 'National ID', verified: true),
      _VerificationItem(label: 'Cooperative Endorsement', verified: _farmProfile?['coop_verified'] == true),
      _VerificationItem(label: 'Farm GPS Location', verified: _farmProfile?['farm_gps'] != null && _farmProfile!['farm_gps'].isNotEmpty),
      _VerificationItem(label: 'Bank Account', verified: false),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Profile',
        showNotificationAction: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
            onPressed: () => setState(() => _isEditing = !_isEditing),
            tooltip: _isEditing ? 'Cancel editing' : 'Edit profile',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavigationBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AppScreen(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Gradient Header ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppGradients.hero,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Avatar(
                                imageUrl: _profileImageUrl,
                                imageFile: _selectedAvatarFile,
                                firstName: _firstName,
                                lastName: _lastName,
                                username: _username,
                                size: 72,
                                showBorder: false,
                              ),
                              if (_isEditing)
                                IconButton.filled(
                                  tooltip: 'Change photo',
                                  iconSize: 16,
                                  constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                                  padding: EdgeInsets.zero,
                                  onPressed: _pickAvatarImage,
                                  icon: const Icon(Icons.camera_alt, size: 14),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName.isNotEmpty ? displayName : (_username ?? 'Your profile'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _phoneController.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withOpacity(0.3),
                                    borderRadius: AppRadius.small,
                                  ),
                                  child: Text(
                                    displayRole.isNotEmpty ? '✓ $displayRole' : 'Guest',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Stats Cards ──────────────────────────────────────────
                    if (stats.isNotEmpty)
                      Row(
                        children: stats.map((stat) {
                          return Expanded(
                            child: CustomCard(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              margin: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  Text(
                                    stat.value,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stat.label,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    if (stats.isNotEmpty) const SizedBox(height: 24),

                    // ─── Verification Status ──────────────────────────────────
                    SectionHeader(
                      title: 'Verification Status',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    CustomCard(
                      padding: const EdgeInsets.all(16),
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: verifications.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.label,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textDark,
                                  ),
                                ),
                                if (item.verified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.15),
                                      borderRadius: AppRadius.small,
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.check_circle, color: AppColors.success, size: 14),
                                        SizedBox(width: 4),
                                        Text('Verified', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withOpacity(0.15),
                                      borderRadius: AppRadius.small,
                                    ),
                                    child: const Text('Add', style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w700)),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Menu Items ───────────────────────────────────────────
                    _buildMenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Wallet & Payouts',
                      subtitle: 'M-Pesa · Bank',
                      onTap: () {
                        // TODO: Navigate to wallet page
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      subtitle: 'Order, payment alerts',
                      onTap: () {
                        // TODO: Navigate to notifications
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      subtitle: null,
                      onTap: () {
                        // TODO: Navigate to settings
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      subtitle: null,
                      onTap: () {
                        // TODO: Navigate to support
                      },
                    ),
                    const SizedBox(height: 24),

                    // ─── Logout Button ─────────────────────────────────────────
                    CustomCard(
                      margin: EdgeInsets.zero,
                      color: AppColors.error.withOpacity(0.08),
                      border: BorderSide(color: AppColors.error.withOpacity(0.2)),
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: AppColors.error),
                        title: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.error),
                        onTap: _confirmLogout,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Edit Form (Visible when in edit mode) ──────────────
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
                        isLoading: _loading,
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
    );
  }

  Widget _buildMenuItem({required IconData icon, required String label, String? subtitle, required VoidCallback onTap}) {
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
        title: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: subtitle != null ? Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted)) : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

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

    setState(() => _loading = true);
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
    } catch (e) {
      CustomSnackbar.showError(context, 'Photo upload failed: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
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

  // Helper widgets
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

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