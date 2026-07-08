// mobile/lib/features/auth/pages/retailer_register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class RetailerRegisterPage extends StatefulWidget {
  const RetailerRegisterPage({super.key});

  @override
  State<RetailerRegisterPage> createState() => _RetailerRegisterPageState();
}

class _RetailerRegisterPageState extends State<RetailerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _kraPinController = TextEditingController();
  String _selectedBusinessType = 'Grocery / Supermarket';

  final List<String> _businessTypes = [
    'Grocery / Supermarket',
    'Restaurant',
    'Hotel / Catering',
    'Market Stall',
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    _businessAddressController.dispose();
    _kraPinController.dispose();
    super.dispose();
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
          ctx.go(RoutePaths.success, extra: 'retailer');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Retailer Registration'),
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
                _buildProgressIndicator(4, 'Business Details'),
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: AppRadius.xl,
                        ),
                        child: Image.asset(
                          'assets/icons/secure_payment_icon.png',
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
                            color: AppColors.primaryGreen,
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
                  controller: _businessNameController,
                  label: 'Business Name',
                  hint: 'Kamau Fresh Groceries',
                  validator: (v) => v == null || v.isEmpty ? 'Enter business name' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _ownerNameController,
                  label: 'Owner Full Name',
                  hint: 'James Kamau',
                  validator: (v) => v == null || v.isEmpty ? 'Enter owner name' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _businessPhoneController,
                  label: 'Business Phone',
                  hint: '+254 7XX XXX XXX',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter business phone' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _businessEmailController,
                  label: 'Business Email',
                  hint: 'info@kamaufresh.co.ke',
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
                  controller: _businessAddressController,
                  label: 'Business Address',
                  hint: 'Tom Mboya St, Nairobi',
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter business address' : null,
                ),
                const SizedBox(height: 16),
                // Business Type Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Type',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.2),
                        ),
                        borderRadius: AppRadius.lg,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedBusinessType,
                        items: _businessTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedBusinessType = value);
                          }
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (_) => _selectedBusinessType.isEmpty ? 'Select a business type' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _kraPinController,
                  label: 'KRA PIN (optional)',
                  hint: 'A000000000Z',
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (ctx, state) {
                    return CustomButton(
                      label: 'Create Account',
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ctx.read<AuthBloc>().add(
                            RegisterRequested(
                              dto: {
                                'role': 'retailer',
                                'business_name': _businessNameController.text.trim(),
                                'owner_full_name': _ownerNameController.text.trim(),
                                'business_phone': _businessPhoneController.text.trim(),
                                'business_email': _businessEmailController.text.trim(),
                                'business_address': _businessAddressController.text.trim(),
                                'business_type': _selectedBusinessType,
                                'kra_pin': _kraPinController.text.trim().isEmpty
                                    ? null
                                    : _kraPinController.text.trim(),
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
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: step / 4,
          minHeight: 6,
          backgroundColor: AppColors.lightGreen,
          color: AppColors.primaryGreen,
          borderRadius: AppRadius.full,
        ),
      ],
    );
  }
}