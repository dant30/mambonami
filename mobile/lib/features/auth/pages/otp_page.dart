// mobile/lib/features/auth/pages/otp_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../config/role_routes.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class OtpPage extends StatefulWidget {
  final String? phone;
  final String? mode;
  final Map<String, dynamic>? data;

  const OtpPage({super.key, this.phone, this.mode, this.data});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  int _resendSeconds = 45;
  Timer? _countdownTimer;
  String? _error;
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendSeconds = 45);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds -= 1);
    });
  }

  void _resendCode(BuildContext context) {
    if (_resendSeconds != 0) return;

    final phone = widget.phone?.trim() ?? '';
    final mode = widget.mode ?? 'login';
    if (phone.isEmpty) {
      setState(() => _error = 'Missing phone number to resend OTP.');
      return;
    }

    if (mode == 'register') {
      final dto = widget.data ?? {};
      final role = dto['role']?.toString() ?? 'buyer';
      context.read<AuthBloc>().add(RegisterInitEvent(phone, role));
    } else if (mode == 'forgot_password') {
      context.read<AuthBloc>().add(ForgotPasswordInitEvent(phone));
    }

    _startCountdown();
  }

  bool _isSubmitting = false;

  void _submitOtp(String otp) {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final phone = widget.phone ?? '';
    final mode = widget.mode ?? 'login';

    if (mode == 'register') {
      final dto = widget.data ?? {};
      final username = dto['username']?.toString() ??
          dto['full_name']?.toString() ??
          dto['owner_full_name']?.toString() ??
          dto['business_name']?.toString() ??
          'user';
      final password = dto['password']?.toString() ?? 'Mambonami@123';
      context.read<AuthBloc>().add(
            RegisterVerifyEvent(
              phone: phone,
              otp: otp,
              username: username,
              password: password,
              role: dto['role']?.toString() ?? 'buyer',
              email: dto['email']?.toString(),
              fullName: dto['full_name']?.toString(),
              ownerFullName: dto['owner_full_name']?.toString(),
              nationalId: dto['national_id']?.toString(),
              farmGps: dto['farm_gps']?.toString(),
              mpesaNumber: dto['mpesa_number']?.toString(),
              cooperative: dto['cooperative']?.toString(),
              vehicleType: dto['vehicle_type']?.toString(),
              licensePlate: dto['license_plate']?.toString(),
              driverLicense: dto['driver_license']?.toString(),
              bankAccount: dto['bank_account']?.toString(),
              deliveryAddress: dto['delivery_address']?.toString(),
              deliveryInstructions: dto['delivery_instructions']?.toString(),
              businessName: dto['business_name']?.toString(),
              businessPhone: dto['business_phone']?.toString(),
              businessEmail: dto['business_email']?.toString(),
              businessAddress: dto['business_address']?.toString(),
              businessType: dto['business_type']?.toString(),
              kraPin: dto['kra_pin']?.toString(),
            ),
          );
      return;
    }

    if (mode == 'forgot_password') {
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        setState(() => _error = 'Enter and confirm your new password.');
        return;
      }
      if (newPassword != confirmPassword) {
        setState(() => _error = 'Passwords do not match.');
        return;
      }
      if (newPassword.length < 8) {
        setState(() => _error = 'Password must be at least 8 characters.');
        return;
      }

      context.read<AuthBloc>().add(
            ForgotPasswordVerifyEvent(
              phone: phone,
              otp: otp,
              newPassword: newPassword,
            ),
          );
      return;
    }

    context.read<AuthBloc>().add(
          OtpVerifyRequested(
            phone: phone,
            otp: otp,
          ),
        );
  }

  String get _maskedPhone {
    final phone = (widget.phone ?? '').trim();
    if (phone.isEmpty) return 'your phone';
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 4)} *** ${phone.substring(phone.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (widget.mode == 'register') {
            context.go(RoutePaths.success, extra: {'role': state.role});
          } else {
            context.go(AppRole.homePathFor(state.role));
          }
        } else if (state is RegisterSuccess && widget.mode == 'register') {
          context.go(RoutePaths.success, extra: {'role': state.role});
        } else if (state is RegisterInitSuccess && widget.mode == 'register') {
          setState(() {
            _error = null;
            _startCountdown();
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification code resent.')),
          );
        } else if (state is ForgotPasswordInitSuccess && widget.mode == 'forgot_password') {
          setState(() {
            _error = null;
            _startCountdown();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reset code resent.')),
          );
        } else if (state is ForgotPasswordSuccess) {
          _isSubmitting = false;
          context.go(RoutePaths.login);
        } else if (state is AuthError) {
          setState(() {
            _error = state.message;
            _isSubmitting = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button (aligned left)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => context.go(RoutePaths.login),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 20),

                // Icon tile (phone icon)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: AppRadius.lg,
                  ),
                  child: Icon(
                    Icons.phone_rounded,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Verify your phone',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle with masked phone
                RichText(
                  text: TextSpan(
                    text: 'We sent a 4-digit code to\n',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(
                        text: _maskedPhone,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // OTP input using Pinput
                Pinput(
                  length: 4,
                  controller: _otpController,
                  onCompleted: (otp) {
                    _submitOtp(otp);
                  },
                  defaultPinTheme: PinTheme(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadius.lg,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                        width: 1.8,
                      ),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: AppRadius.lg,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: AppRadius.lg,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (widget.mode == 'forgot_password') ...[
                  CustomTextField(
                    controller: _newPasswordController,
                    label: 'New password',
                    hint: 'Enter new password',
                    obscureText: _isPasswordHidden,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordHidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm password',
                    hint: 'Re-enter new password',
                    obscureText: _isConfirmPasswordHidden,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordHidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() {
                        _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                      }),
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Verify button
                CustomButton(
                  label: 'Verify & Continue',
                  enabled: !_isSubmitting,
                  onPressed: () {
                    final otp = _otpController.text.trim();
                    if (otp.length == 4) {
                      _submitOtp(otp);
                    } else {
                      setState(() {
                        _error = 'Enter 4-digit OTP';
                        _isSubmitting = false;
                      });
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: 16),

                // Timer and resend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 13,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _resendSeconds > 0
                          ? 'Resend code in 00:${_resendSeconds.toString().padLeft(2, '0')}'
                          : 'Resend code available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _resendSeconds == 0 ? () => _resendCode(context) : null,
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: _resendSeconds == 0
                          ? AppColors.secondary
                          : AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
