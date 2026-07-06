// mobile/lib/features/auth/pages/register_verify_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/role_routes.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../widgets/auth_surface.dart';

class RegisterVerifyPage extends StatefulWidget {
  final String phone;
  final String role;

  const RegisterVerifyPage({
    super.key,
    required this.phone,
    required this.role,
  });

  @override
  State<RegisterVerifyPage> createState() => _RegisterVerifyPageState();
}

class _RegisterVerifyPageState extends State<RegisterVerifyPage> {
  final _otpController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _farmGpsController = TextEditingController();
  final _mpesaController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  int _resendSeconds = 45;
  Timer? _resendTimer;
  String _selectedVehicleType = 'motorcycle';

  static const List<String> _vehicleTypes = [
    'motorcycle',
    'pickup',
    'lorry',
    'van',
  ];

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _farmGpsController.dispose();
    _mpesaController.dispose();
    _licensePlateController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 45);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds -= 1);
    });
  }

  void _resendOtp() {
    if (_resendSeconds == 0) {
      _startResendTimer();
      CustomSnackbar.showSuccess(context, 'Verification code resent.');
    }
  }

  void _verify() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterVerifyEvent(
              phone: widget.phone,
              otp: _otpController.text.trim(),
              username: _usernameController.text.trim(),
              password: _passwordController.text,
              role: widget.role,
              email: _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
              farmGps:
                  widget.role == 'farmer' ? _farmGpsController.text.trim() : null,
              mpesaNumber: widget.role == 'farmer'
                  ? _mpesaController.text.trim()
                  : null,
              vehicleType: widget.role == 'transport_provider'
                  ? _selectedVehicleType
                  : null,
              licensePlate: widget.role == 'transport_provider'
                  ? _licensePlateController.text.trim()
                  : null,
            ),
          );
    }
  }

  String get _roleLabel => widget.role.replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(RoutePaths.success, extra: {'role': state.role});
          } else if (state is AuthError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Green Gradient Header ─────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white),
                        onPressed: () => context.go(
                          AppRole.registrationPathFor(widget.role),
                          extra: {'role': widget.role},
                        ),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 4),
                      // Title
                      Text(
                        'Verify your account',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete your secure marketplace profile for ${_roleLabel.toLowerCase()} access.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Summary row (phone & role)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _summaryChip(Icons.phone_outlined, widget.phone),
                            const SizedBox(width: 16),
                            _summaryChip(Icons.badge_outlined,
                                _roleLabel.toUpperCase()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Form (scrollable) ──────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: AuthSurface(
                      margin: EdgeInsets.zero,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AuthStepBadge(
                              label: 'Final step: OTP and profile',
                              icon: Icons.verified_user_outlined,
                            ),
                            const SizedBox(height: 16),

                            // OTP hint
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.sms_outlined,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'We have sent a secure one-time passcode to ${widget.phone}. Enter it below to finish setting up your account.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme.colorScheme
                                            .onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // OTP input
                            Pinput(
                              controller: _otpController,
                              length: 4,
                              defaultPinTheme: PinTheme(
                                width: 60,
                                height: 60,
                                textStyle: theme.textTheme.headlineSmall
                                    ?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outline,
                                    width: 1.8,
                                  ),
                                ),
                              ),
                              focusedPinTheme: PinTheme(
                                width: 60,
                                height: 60,
                                textStyle: theme.textTheme.headlineSmall
                                    ?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2.2,
                                  ),
                                ),
                              ),
                              submittedPinTheme: PinTheme(
                                width: 60,
                                height: 60,
                                textStyle: theme.textTheme.headlineSmall
                                    ?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2.2,
                                  ),
                                ),
                              ),
                              showCursor: true,
                              onCompleted: (value) =>
                                  _otpController.text = value,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _resendSeconds > 0
                                      ? 'Resend in 00:${_resendSeconds.toString().padLeft(2, '0')}'
                                      : 'Resend available',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _resendSeconds == 0
                                      ? _resendOtp
                                      : null,
                                  child: const Text('Resend'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Username
                            CustomTextField(
                              controller: _usernameController,
                              label: 'Username',
                              hintText: 'mambo_user',
                              prefixIcon: const Icon(Icons.person_outline),
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Required'
                                      : null,
                            ),
                            const SizedBox(height: 14),

                            // Password
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: 'Create a secure password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              obscureText: _isPasswordHidden,
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  value == null || value.length < 6
                                      ? 'Min 6 chars'
                                      : null,
                              suffixIcon: IconButton(
                                tooltip: _isPasswordHidden
                                    ? 'Show password'
                                    : 'Hide password',
                                icon: Icon(
                                  _isPasswordHidden
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(() {
                                  _isPasswordHidden = !_isPasswordHidden;
                                }),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Confirm password
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hintText: 'Re-enter your password',
                              prefixIcon: const Icon(Icons.lock_person_outlined),
                              obscureText: _isConfirmPasswordHidden,
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  value != _passwordController.text
                                      ? 'Passwords do not match'
                                      : null,
                              suffixIcon: IconButton(
                                tooltip: _isConfirmPasswordHidden
                                    ? 'Show password'
                                    : 'Hide password',
                                icon: Icon(
                                  _isConfirmPasswordHidden
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(() {
                                  _isConfirmPasswordHidden =
                                      !_isConfirmPasswordHidden;
                                }),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Email (optional)
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email (optional)',
                              prefixIcon: const Icon(Icons.mail_outline),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    !value.contains('@')) {
                                  return 'Enter valid email';
                                }
                                return null;
                              },
                            ),

                            // Role-specific fields
                            if (widget.role == 'farmer') ...[
                              const SizedBox(height: 18),
                              _RoleSectionHeader(
                                icon: Icons.agriculture_outlined,
                                title: 'Farmer details',
                                color: AppColors.farmerAccent,
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: _farmGpsController,
                                label: 'Farm GPS (lat,lng)',
                                prefixIcon: const Icon(Icons.map_outlined),
                                textInputAction: TextInputAction.next,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Required for farmers'
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              CustomTextField(
                                controller: _mpesaController,
                                label: 'M-Pesa Number',
                                prefixIcon: const Icon(Icons.payments_outlined),
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Required for farmers'
                                        : null,
                              ),
                            ],

                            if (widget.role == 'transport_provider') ...[
                              const SizedBox(height: 18),
                              _RoleSectionHeader(
                                icon: Icons.local_shipping_outlined,
                                title: 'Transport provider details',
                                color: AppColors.providerAccent,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedVehicleType,
                                decoration: const InputDecoration(
                                  labelText: 'Vehicle Type',
                                  prefixIcon: Icon(Icons.fire_truck_outlined),
                                ),
                                items: _vehicleTypes
                                    .map(
                                      (type) => DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(
                                          type[0].toUpperCase() +
                                              type.substring(1),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() =>
                                        _selectedVehicleType = value);
                                  }
                                },
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Required for transport providers'
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              CustomTextField(
                                controller: _licensePlateController,
                                label: 'License Plate',
                                prefixIcon: const Icon(
                                    Icons.confirmation_number_outlined),
                                textInputAction: TextInputAction.done,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Required for transport providers'
                                        : null,
                              ),
                            ],

                            const SizedBox(height: 22),
                            CustomButton(
                              onPressed: _verify,
                              isLoading: isLoading,
                              label: 'Complete registration',
                              icon: const Icon(Icons.verified_outlined),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your details help keep marketplace payments, deliveries, and order ownership secure.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper: summary chip inside header
  Widget _summaryChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _RoleSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _RoleSectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}