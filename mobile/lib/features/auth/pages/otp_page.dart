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
  int _resendSeconds = 45;
  Timer? _countdownTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
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

  void _resendCode() {
    if (_resendSeconds == 0) {
      _startCountdown();
      // Optionally dispatch a resend OTP event to the BLoC
      // context.read<AuthBloc>().add(ResendOtpEvent(widget.phone ?? ''));
    }
  }

  void _submitOtp(String otp) {
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
          farmGps: dto['farm_gps']?.toString(),
          mpesaNumber: dto['mpesa_number']?.toString(),
          vehicleType: dto['vehicle_type']?.toString(),
          licensePlate: dto['license_plate']?.toString(),
        ),
      );
      return;
    }

    if (mode == 'forgot_password') {
      context.read<AuthBloc>().add(
        ForgotPasswordVerifyEvent(
          phone: phone,
          otp: otp,
          newPassword: widget.data?['new_password']?.toString() ?? '',
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
          context.go(AppRole.homePathFor(state.role));
        } else if (state is ForgotPasswordSuccess) {
          context.go(RoutePaths.login);
        } else if (state is AuthError) {
          setState(() => _error = state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                    color: AppColors.lightGreen,
                    borderRadius: AppRadius.lg,
                  ),
                  child: const Icon(
                    Icons.phone_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Verify your phone',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.dark,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
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
                      color: Colors.white,
                      borderRadius: AppRadius.lg,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
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
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Verify button
                CustomButton(
                  label: 'Verify & Continue',
                  onPressed: () {
                    final otp = _otpController.text.trim();
                    if (otp.length == 4) {
                      _submitOtp(otp);
                    } else {
                      setState(() => _error = 'Enter 4-digit OTP');
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
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
                  onPressed: _resendSeconds == 0 ? _resendCode : null,
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