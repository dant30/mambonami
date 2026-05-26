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
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../shared/widgets/app_navigation.dart';
import '../../shared/widgets/avatar.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  String? _profileImageUrl;
  File? _selectedAvatarFile;
  String? _firstName;
  String? _lastName;
  String? _username;

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
      _phoneController.text = profile['phone']?.toString() ??
          (context.read<AuthBloc>().state is AuthAuthenticated
              ? (context.read<AuthBloc>().state as AuthAuthenticated).phone
              : '');

      setState(() {
        _profileImageUrl = profile['profile_image']?.toString();
        _selectedAvatarFile = null;
        _firstName = profile['first_name']?.toString();
        _lastName = profile['last_name']?.toString();
        _username = profile['username']?.toString();
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Column(
                            children: [
                              Avatar(
                                imageUrl: _profileImageUrl,
                                imageFile: _selectedAvatarFile,
                                firstName: _firstName,
                                lastName: _lastName,
                                username: _username,
                                size: 80,
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _pickAvatarImage,
                                child: Text(
                                  'Change photo',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 30,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAvatarImage,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (displayName.isNotEmpty)
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    const SizedBox(height: 24),
                    SectionHeader(
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
                    SectionHeader(
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
                    SectionHeader(
                      title: 'Actions',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(onPressed: _saveProfile, isLoading: _loading, label: 'Save Changes'),
                    const SizedBox(height: 12),
                    CustomButton(
                      onPressed: _confirmLogout,
                      label: 'Log out',
                      color: Colors.redAccent,
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
  }}