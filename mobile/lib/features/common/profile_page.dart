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

      final fullName = [profile['first_name']?.toString(), profile['last_name']?.toString()].where((value) => value != null && value.isNotEmpty).join(' ').trim();
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
    final displayName = '${_firstName ?? ''} ${_lastName ?? ''}'.trim();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavigationBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AppScreen(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomCard(
                      margin: EdgeInsets.zero,
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
                                size: 76,
                              ),
                              IconButton.filled(
                                tooltip: 'Change photo',
                                iconSize: 17,
                                constraints: const BoxConstraints.tightFor(
                                  width: 32,
                                  height: 32,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: _pickAvatarImage,
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName.isNotEmpty
                                      ? displayName
                                      : (_username ?? 'Your profile'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _phoneController.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                if (_role != null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    _role!.replaceAll('_', ' ').toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ],
                                if ((_location ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    _location!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
                    if (_role != null) ...[
                      const SectionHeader(
                        title: 'Profile Summary',
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
                      CustomCard(
                        margin: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Role: ${_role!}', style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(height: 12),
                            if (_transportProfile != null) ...[
                              _buildStatRow('Deliveries', '${_transportProfile!['total_deliveries'] ?? '—'}'),
                              const SizedBox(height: 8),
                              _buildStatRow('Rating', '${_transportProfile!['rating'] ?? '—'}'),
                              const SizedBox(height: 8),
                              _buildStatRow('Vehicle', '${_transportProfile!['vehicle_type'] ?? '—'}'),
                              const SizedBox(height: 8),
                              _buildStatRow('Approved', _transportProfile!['is_approved'] == true ? 'Yes' : 'No'),
                            ],
                            if (_farmProfile != null) ...[
                              _buildStatRow('Total sales', '${_farmProfile!['total_sales'] ?? '—'}'),
                              const SizedBox(height: 8),
                              _buildStatRow('M-Pesa', '${_farmProfile!['mpesa_number'] ?? '—'}'),
                              const SizedBox(height: 8),
                              _buildStatRow('Coop verified', _farmProfile!['coop_verified'] == true ? 'Yes' : 'No'),
                            ],
                            if ((_role ?? '').toLowerCase() == 'farmer') ...[
                              const SizedBox(height: 8),
                              _buildStatRow('Farm', '${_farmProfile?['farm_name'] ?? '—'}'),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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
                    CustomButton(onPressed: _saveProfile, isLoading: _loading, label: 'Save Changes'),
                    const SizedBox(height: 12),
                    CustomButton(
                      onPressed: _confirmLogout,
                      label: 'Log out',
                      color: Theme.of(context).colorScheme.error,
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
                ),
              ),
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
