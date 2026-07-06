// mobile/lib/features/auth/pages/otp_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/otp_input_field.dart';

class OtpPage extends StatefulWidget {
  final String phone;

  const OtpPage({super.key, required this.phone});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  int _resendSeconds = 45;
  Timer? _countdownTimer;

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

  void _verifyOtp() {
    if (_otpController.text.trim().length == 4) {
      // In production, the OTP validation would be handled by the AuthBloc.
      // For UI prototyping, we navigate directly to role selection.
      context.go(RoutePaths.roleSelect, extra: {'phone': widget.phone});
    }
  }

  void _resendCode() {
    if (_resendSeconds == 0) {
      _startCountdown();
      // Optionally call an API to resend OTP.
    }
  }

  String get _maskedPhone {
    final phone = widget.phone.trim();
    if (phone.length < 7) return phone.isEmpty ? 'your phone' : phone;
    return '${phone.substring(0, 4)}***${phone.substring(phone.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button (aligned left)
              Align(
                alignment: Alignment.centerLeft,
                child: _AuthBackButton(
                  onPressed: () => context.go(RoutePaths.login),
                ),
              ),
              const SizedBox(height: 24),

              // Icon tile
              _AuthIconTile(icon: Icons.phone_outlined),
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

              // Subtitle with masked phone number
              Text(
                'We sent a 4-digit code to\n$_maskedPhone',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // OTP input field (custom widget with 4 boxes)
              OtpInputField(
                controller: _otpController,
                onCompleted: (value) => _otpController.text = value,
                fieldWidth: 62,
                spacing: 12,
                // Customize decoration to look like prototype boxes
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                inputDecorationBuilder: (context, child) {
                  // This allows us to wrap each box with a border
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1.8,
                      ),
                    ),
                    child: child,
                  );
                },
              ),
              const SizedBox(height: 28),

              // Verify button
              CustomButton(
                onPressed: _verifyOtp,
                label: 'Verify & Continue',
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              const SizedBox(height: 20),

              // Timer and resend
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.muted,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthIconTile extends StatelessWidget {
  final IconData icon;

  const _AuthIconTile({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceHighLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: AppColors.primary, size: 28),
      ),
    );
  }
}

class _AuthBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AuthBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHighLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
}