// lib/features/profile/profile_page.dart
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
import '../../data/repositories/verification_repository.dart';
import '../../shared/layouts/app_navigation.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_gradients.dart';
import '../../shared/utils/form_validators.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/custom_image_picker.dart';
import '../../shared/widgets/custom_snackbar.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/section_header.dart';

// Role-specific content widgets
import 'widgets/farmer_profile_content.dart';
import 'widgets/transport_profile_content.dart';
import 'widgets/buyer_profile_content.dart';
import 'widgets/retailer_profile_content.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/profile_stat_tile.dart';

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

  final _farmGpsController = TextEditingController();
  final _cooperativeController = TextEditingController();
  final _mpesaController = TextEditingController();
  final _profileBankAccountController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _driverLicenseController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _deliveryInstructionsController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _kraPinController = TextEditingController();
  final _businessRegistrationNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  bool _isDeletingAccount = false;
  bool _isEditing = false;

  // Profile data (common + role-specific)
  Map<String, dynamic> _profileData = {};
  String? _profileImageUrl;
  File? _selectedAvatarFile;
  String? _firstName;
  String? _lastName;
  String? _username;
  String? _role;
  Map<String, dynamic>? _roleProfile; // farmer_profile, transport_profile, etc.

  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  final VerificationRepository _verificationRepository = GetIt.I<VerificationRepository>();
  double? _trustScoreProfile;

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
    _farmGpsController.dispose();
    _cooperativeController.dispose();
    _mpesaController.dispose();
    _profileBankAccountController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    _driverLicenseController.dispose();
    _deliveryAddressController.dispose();
    _deliveryInstructionsController.dispose();
    _businessNameController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    _businessAddressController.dispose();
    _businessTypeController.dispose();
    _kraPinController.dispose();
    _businessRegistrationNumberController.dispose();
    super.dispose();
  }

  // ── Data loading ─────────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _authRepository.getProfile();
      _profileData = profile;
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
      _roleProfile = _resolveRoleProfile(profile);
      _profileImageUrl = _resolveProfileImage(profile);
      _selectedAvatarFile = null;
      _firstName = profile['first_name']?.toString();
      _lastName = profile['last_name']?.toString();
      _username = profile['username']?.toString();

      final roleData = _roleProfile ?? {};
      _farmGpsController.text = roleData['farm_gps']?.toString() ?? '';
      _cooperativeController.text = roleData['cooperative']?.toString() ?? '';
      _mpesaController.text = roleData['mpesa_number']?.toString() ?? '';
      _profileBankAccountController.text = roleData['bank_account']?.toString() ?? '';
      _vehicleTypeController.text = roleData['vehicle_type']?.toString() ?? '';
      _licensePlateController.text = roleData['license_plate']?.toString() ?? '';
      _driverLicenseController.text = roleData['driver_license']?.toString() ?? '';
      _deliveryAddressController.text = roleData['delivery_address']?.toString() ?? '';
      _deliveryInstructionsController.text = roleData['delivery_instructions']?.toString() ?? '';
      _businessNameController.text = roleData['business_name']?.toString() ?? '';
      _businessPhoneController.text = roleData['business_phone']?.toString() ?? '';
      _businessEmailController.text = roleData['business_email']?.toString() ?? '';
      _businessAddressController.text = roleData['business_address']?.toString() ?? '';
      _businessTypeController.text = roleData['business_type']?.toString() ?? '';
      _kraPinController.text = roleData['kra_pin']?.toString() ?? '';
      _businessRegistrationNumberController.text = roleData['business_registration_number']?.toString() ?? '';
    } catch (e) {
      CustomSnackbar.showError(context, 'Failed to load profile: ${e.toString()}');
    } finally {
      // Attempt to load trust score separately
      _loadTrustScore();
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTrustScore() async {
    try {
      final scoreMap = await _verificationRepository.getTrustScore();
      final scoreVal = scoreMap['score'] ?? scoreMap['trust_score'] ?? scoreMap['value'];
      double? val;
      if (scoreVal is num) {
        val = scoreVal.toDouble();
      } else {
        val = double.tryParse(scoreVal?.toString() ?? '');
      }
      setState(() { _trustScoreProfile = val; });
    } catch (_) {
      // ignore
    }
  }

  Map<String, dynamic>? _resolveRoleProfile(Map<String, dynamic> profile) {
    switch (_role) {
      case 'farmer':
        return profile['farm_profile'] as Map<String, dynamic>?;
      case 'transport_provider':
        return profile['transport_profile'] as Map<String, dynamic>?;
      case 'buyer':
        return profile['buyer_profile'] as Map<String, dynamic>?;
      case 'retailer':
        return profile['retailer_profile'] as Map<String, dynamic>?;
      default:
        return null;
    }
  }

  String? _resolveProfileImage(Map<String, dynamic> profile) {
    for (final key in const ['profile_image', 'profileImage', 'avatar_url', 'avatarUrl', 'avatar']) {
      final value = profile[key]?.toString();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  // ── Save common fields ──────────────────────────────────────────────────
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

      if (_role == 'farmer') {
        payload.addAll({
          'farm_gps': _farmGpsController.text.trim(),
          'cooperative': _cooperativeController.text.trim(),
          'mpesa_number': _mpesaController.text.trim(),
          'bank_account': _profileBankAccountController.text.trim(),
        });
      } else if (_role == 'transport_provider') {
        payload.addAll({
          'vehicle_type': _vehicleTypeController.text.trim(),
          'license_plate': _licensePlateController.text.trim(),
          'driver_license': _driverLicenseController.text.trim(),
          'bank_account': _profileBankAccountController.text.trim(),
        });
      } else if (_role == 'buyer') {
        payload.addAll({
          'delivery_address': _deliveryAddressController.text.trim(),
          'delivery_instructions': _deliveryInstructionsController.text.trim(),
          'bank_account': _profileBankAccountController.text.trim(),
        });
      } else if (_role == 'retailer') {
        payload.addAll({
          'business_name': _businessNameController.text.trim(),
          'business_phone': _businessPhoneController.text.trim(),
          'business_email': _businessEmailController.text.trim(),
          'business_address': _businessAddressController.text.trim(),
          'business_type': _businessTypeController.text.trim(),
          'kra_pin': _kraPinController.text.trim(),
          'business_registration_number': _businessRegistrationNumberController.text.trim(),
          'bank_account': _profileBankAccountController.text.trim(),
        });
      }
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

  // ── Avatar picker ──────────────────────────────────────────────────────
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
        'avatar': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });
      await api.dio.patch(kProfileAvatarEndpoint, data: formData);
      setState(() { _selectedAvatarFile = file; });
      CustomSnackbar.showSuccess(context, 'Profile photo updated');
      await _loadProfile();
    } catch (e) {
      CustomSnackbar.showError(context, 'Photo upload failed: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ── Password change ──────────────────────────────────────────────────
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

  // ── Delete account ────────────────────────────────────────────────────
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

  // ─── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
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
          // ─── Header ────────────────────────────────────────────────
          _buildHeader(),
          // ─── Body ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Stats row ────────────────────────────────────
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  // ─── Verification ──────────────────────────────────
                  _buildVerificationSection(),
                  const SizedBox(height: 14),
                  if (!_isEditing) ...[
                    if (_role == 'farmer')
                      FarmerProfileContent(
                        farmProfile: _roleProfile,
                        isEditing: false,
                      ),
                    if (_role == 'transport_provider')
                      TransportProfileContent(
                        transportProfile: _roleProfile,
                        isEditing: false,
                      ),
                    if (_role == 'buyer')
                      BuyerProfileContent(
                        buyerProfile: _roleProfile,
                        isEditing: false,
                      ),
                    if (_role == 'retailer')
                      RetailerProfileContent(
                        retailerProfile: _roleProfile,
                        isEditing: false,
                      ),
                    const SizedBox(height: 24),
                  ],
                  // ─── Menu items ────────────────────────────────────
                  _buildMenuItems(),
                  const SizedBox(height: 24),
                  // ─── Logout ────────────────────────────────────────
                  _buildLogoutButton(),
                  const SizedBox(height: 24),
                  // ─── Edit form (if editing) ──────────────────────
                  if (_isEditing) _buildEditForm(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }

  // ─── Header widget ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      decoration: BoxDecoration(gradient: AppGradients.hero),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RoutePaths.buyerDashboard);
                  }
                },
              ),
              const Expanded(
                child: Text(
                  'My Profile',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
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
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 13),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _displayName,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            _phoneController.text,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
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
              style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _trustScoreProfile != null && _trustScoreProfile! >= 70
                      ? AppColors.success.withValues(alpha: 0.22)
                      : AppColors.gold.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _trustScoreProfile != null
                      ? 'Trust ${_formatTrustScore(_trustScoreProfile!)}'
                      : 'Trust —',
                  style: TextStyle(
                    color: _trustScoreProfile != null && _trustScoreProfile! >= 70
                        ? AppColors.success
                        : AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => context.go(
                  RoutePaths.verificationDocuments,
                  extra: {'type': 'national_id', 'direct': true},
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text(
                  'Upload National ID',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _displayName {
    final full = '${_firstName ?? ''} ${_lastName ?? ''}'.trim();
    return full.isNotEmpty ? full : (_username ?? 'User');
  }

  String get _displayRole {
    if (_role == null) return '';
    return _role!.replaceAll('_', ' ').toUpperCase();
  }

  // ─── Stats row ──────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    List<_StatItem> stats;
    if (_role == 'farmer') {
      final farm = _roleProfile ?? {};
      stats = [
        _StatItem(label: 'Earnings', value: 'KES ${farm['total_sales'] ?? '0'}'),
        _StatItem(label: 'Rating', value: '${farm['rating'] ?? '4.8'} ★'),
        _StatItem(label: 'Orders', value: farm['total_orders']?.toString() ?? '0'),
      ];
    } else if (_role == 'transport_provider') {
      final transport = _roleProfile ?? {};
      stats = [
        _StatItem(label: 'Deliveries', value: transport['total_deliveries']?.toString() ?? '0'),
        _StatItem(label: 'Rating', value: '${transport['rating'] ?? '4.8'} ★'),
        _StatItem(label: 'Trips', value: transport['total_trips']?.toString() ?? '0'),
      ];
    } else {
      stats = const [
        _StatItem(label: 'Orders', value: '0'),
        _StatItem(label: 'Rating', value: '4.5 ★'),
        _StatItem(label: 'Items', value: '0'),
      ];
    }
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: ProfileStatTile(value: stat.value, label: stat.label),
        );
      }).toList(),
    );
  }

  // ─── Verification section ──────────────────────────────────────────────
  Widget _buildVerificationSection() {
    List<_VerificationItem> items;
    if (_role == 'farmer') {
      final farm = _roleProfile ?? {};
      items = [
        const _VerificationItem(label: 'Phone Number', verified: true),
        const _VerificationItem(label: 'National ID', verified: true),
        _VerificationItem(label: 'Cooperative Endorsement', verified: farm['coop_verified'] == true),
        _VerificationItem(label: 'Farm GPS Location', verified: farm['farm_gps'] != null && farm['farm_gps'].isNotEmpty),
        const _VerificationItem(label: 'Bank Account', verified: false),
      ];
    } else if (_role == 'transport_provider') {
      final transport = _roleProfile ?? {};
      items = [
        const _VerificationItem(label: 'Phone Number', verified: true),
        const _VerificationItem(label: 'National ID', verified: true),
        _VerificationItem(label: 'Vehicle Registration', verified: transport['license_plate'] != null && transport['license_plate'].isNotEmpty),
        _VerificationItem(label: 'Driver License', verified: transport['driver_license'] != null && transport['driver_license'].isNotEmpty),
        _VerificationItem(label: 'Deposit Paid', verified: transport['deposit_paid'] == true),
      ];
    } else {
      items = const [
        _VerificationItem(label: 'Phone Number', verified: true),
        _VerificationItem(label: 'Email', verified: true),
        _VerificationItem(label: 'Address', verified: false),
      ];
    }
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.dark),
          ),
          const SizedBox(height: 12),
          ...items.map((v) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(child: Text(v.label, style: const TextStyle(fontSize: 13, color: AppColors.dark))),
                if (v.verified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '✓ Verified',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => context.go(RoutePaths.verificationDocuments, extra: _mapLabelToType(v.label)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('+ Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _mapLabelToType(String label) {
    final l = label.toLowerCase();
    if (l.contains('national')) return 'national_id';
    if (l.contains('cooperative')) return 'cooperative_endorsement';
    if (l.contains('driver')) return 'driver_license';
    if (l.contains('vehicle')) return 'vehicle_registration';
    if (l.contains('bank')) return 'bank_account';
    if (l.contains('gps')) return 'farm_gps';
    if (l.contains('address')) return 'address';
    return 'other';
  }

  String _formatTrustScore(double score) {
    if (score <= 1) {
      return '${(score * 100).toStringAsFixed(0)}%';
    }
    return '${score.toStringAsFixed(0)}%';
  }

  // ─── Menu items ─────────────────────────────────────────────────────────
  Widget _buildMenuItems() {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Wallet & Payouts',
          subtitle: 'M-Pesa · Bank',
          onTap: () {
            // TODO: Navigate to wallet page
          },
        ),
        const SizedBox(height: 10),
        ProfileMenuItem(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          subtitle: 'Order, payment alerts',
          onTap: () {
            // TODO: Navigate to notifications
          },
        ),
        const SizedBox(height: 10),
        ProfileMenuItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
          subtitle: null,
          onTap: () => context.go(RoutePaths.settings),
        ),
        const SizedBox(height: 10),
        ProfileMenuItem(
          icon: Icons.help_outline,
          label: 'Help & Support',
          subtitle: null,
          onTap: () => context.go(RoutePaths.support),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
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
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Edit form ──────────────────────────────────────────────────────────
  Widget _buildEditForm() {
    // This form is common across all roles.
    return Column(
      children: [
        const Divider(height: 32),
        const SectionHeader(title: 'Personal Information', padding: EdgeInsets.zero),
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
        if (_role == 'farmer')
          FarmerProfileContent(
            farmProfile: _roleProfile,
            isEditing: true,
            farmGpsController: _farmGpsController,
            cooperativeController: _cooperativeController,
            mpesaController: _mpesaController,
            bankAccountController: _profileBankAccountController,
          ),
        if (_role == 'transport_provider')
          TransportProfileContent(
            transportProfile: _roleProfile,
            isEditing: true,
            vehicleTypeController: _vehicleTypeController,
            licensePlateController: _licensePlateController,
            driverLicenseController: _driverLicenseController,
            bankAccountController: _profileBankAccountController,
          ),
        if (_role == 'buyer')
          BuyerProfileContent(
            buyerProfile: _roleProfile,
            isEditing: true,
            deliveryAddressController: _deliveryAddressController,
            deliveryInstructionsController: _deliveryInstructionsController,
            bankAccountController: _profileBankAccountController,
          ),
        if (_role == 'retailer')
          RetailerProfileContent(
            retailerProfile: _roleProfile,
            isEditing: true,
            businessNameController: _businessNameController,
            businessPhoneController: _businessPhoneController,
            businessEmailController: _businessEmailController,
            businessAddressController: _businessAddressController,
            businessTypeController: _businessTypeController,
            kraPinController: _kraPinController,
            businessRegistrationNumberController: _businessRegistrationNumberController,
            bankAccountController: _profileBankAccountController,
          ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Account Settings', padding: EdgeInsets.zero),
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
        const SectionHeader(title: 'Change Password', padding: EdgeInsets.zero),
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
        const SectionHeader(title: 'Actions', padding: EdgeInsets.zero),
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
    );
  }
}

// ─── Helper classes ──────────────────────────────────────────────────────────

class _StatItem {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});
}

class _VerificationItem {
  final String label;
  final bool verified;
  const _VerificationItem({required this.label, required this.verified});
}