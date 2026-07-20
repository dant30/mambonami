// mobile/lib/features/auth/pages/buyer_register.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../core/storage/hive_geocode_cache.dart';
import '../../../data/repositories/geocoding_repository.dart';
import '../../../features/common/map_picker_page.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
import '../../../shared/utils/form_validators.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class BuyerRegisterPage extends StatefulWidget {
  const BuyerRegisterPage({super.key});

  @override
  State<BuyerRegisterPage> createState() => _BuyerRegisterPageState();
}

class _BuyerRegisterPageState extends State<BuyerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  // ignore: prefer_final_fields
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickDeliveryLocation() async {
    final geocodeCache = GetIt.instance<GeocodeCache>();
    final geocodingRepository = GeocodingRepository(geocodeCache);
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          initialAddress: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          geocodingRepository: geocodingRepository,
        ),
      ),
    );

    if (result != null && result['address'] != null) {
      _addressController.text = result['address'].toString();
      setState(() {});
    }
  }

  void _openLegalPage(String path) {
    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is RegisterOtpPending) {
          ctx.go(RoutePaths.otp, extra: {
            'phone': state.phone,
            'mode': 'register',
            'dto': state.dto,
          });
        } else if (state is RegisterSuccess) {
          ctx.go(RoutePaths.success, extra: {'role': 'buyer'});
        } else if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Buyer Registration'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.go(RoutePaths.roleSelect),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressIndicator(4, 'Personal Details'),
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: AppRadius.xl,
                        ),
                        child: Image.asset(
                          'assets/icons/buyer_icon.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: AppRadius.lg,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Mary Wanjiku',
                  validator: (v) => v == null || v.isEmpty ? 'Enter full name' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'mary123',
                  validator: (v) => v == null || v.isEmpty ? 'Enter a username' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: _isPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordHidden ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                  ),
                  validator: FormValidators.validatePassword,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: '••••••••',
                  obscureText: _isConfirmPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordHidden ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isConfirmPasswordHidden = !_isConfirmPasswordHidden),
                  ),
                  validator: (value) => FormValidators.validateConfirmPassword(value, _passwordController.text.trim()),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'mary@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.mail_outlined,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+254 7XX XXX XXX',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter phone number' : null,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: AppRadius.lg,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Address',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Tap to pick on map',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _pickDeliveryLocation,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.md,
                          ),
                        ),
                        child: const Text(
                          'Pick',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: AppRadius.lg,
                    border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Wrap(
                            children: [
                              const Text('I agree to the '),
                              TextButton(
                                onPressed: () => _openLegalPage(RoutePaths.termsAndConditions),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Terms and Conditions'),
                              ),
                              const Text(' and '),
                              TextButton(
                                onPressed: () => _openLegalPage(RoutePaths.privacyPolicy),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Privacy Policy'),
                              ),
                              const Text('.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _instructionsController,
                  label: 'Preferred Delivery Instructions',
                  hint: 'e.g. Call when at gate',
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (ctx, state) {
                    return CustomButton(
                      label: 'Create Account',
                      isLoading: state is AuthLoading,
                      enabled: _acceptedTerms,
                      onPressed: () {
                        if (_formKey.currentState!.validate() && _acceptedTerms) {
                          ctx.read<AuthBloc>().add(
                            RegisterRequested(
                              dto: {
                                'role': 'buyer',
                                'username': _usernameController.text.trim(),
                                'password': _passwordController.text.trim(),
                                'full_name': _fullNameController.text.trim(),
                                'email': _emailController.text.trim(),
                                'phone': _phoneController.text.trim(),
                                'delivery_address': _addressController.text.trim(),
                                'delivery_instructions': _instructionsController.text.trim(),
                              },
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int step, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $step of 4',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: step / 4,
          minHeight: 6,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          color: Theme.of(context).colorScheme.primary,
          borderRadius: AppRadius.full,
        ),
      ],
    );
  }
}