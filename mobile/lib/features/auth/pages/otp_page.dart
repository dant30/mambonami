import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
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
      context.go(RoutePaths.roleSelect, extra: {'phone': widget.phone});
    }
  }

  void _resendCode() {
    if (_resendSeconds == 0) {
      _startCountdown();
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
        child: AppScreen(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _AuthBackButton(
                  onPressed: () => context.go(RoutePaths.login),
                ),
              ),
              const SizedBox(height: 28),
              _AuthIconTile(icon: Icons.phone_outlined),
              const SizedBox(height: 16),
              Text(
                'Verify your phone',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.dark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 4-digit code to\n$_maskedPhone',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              OtpInputField(
                controller: _otpController,
                onCompleted: (value) => _otpController.text = value,
                fieldWidth: 62,
                spacing: 12,
              ),
              const SizedBox(height: 28),
              CustomButton(
                onPressed: _verifyOtp,
                label: 'Verify & Continue',
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              const SizedBox(height: 20),
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
                    child: const Text('Resend OTP'),
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
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceHighLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: AppColors.primary, size: 28),
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
