import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/otp_input_field.dart';
import '../widgets/auth_surface.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maskedPhone = widget.phone.isNotEmpty
        ? widget.phone.replaceRange(4, widget.phone.length - 2, '***')
        : 'your phone';

    return Scaffold(
      appBar: const CustomAppBar(title: 'Verify OTP'),
      body: AppScreen(
        useGradientBackground: true,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.sms_outlined,
                  color: theme.colorScheme.primary,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Verify your phone',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 4-digit code sent to $maskedPhone.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            AuthSurface(
              child: Column(
                children: [
                  OtpInputField(
                    controller: _otpController,
                    onCompleted: (value) => _otpController.text = value,
                    fieldWidth: 62,
                    spacing: 12,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    onPressed: _verifyOtp,
                    label: 'Verify & Continue',
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: _resendSeconds == 0 ? _resendCode : null,
                    child: Text(
                      _resendSeconds > 0
                          ? 'Resend code in 00:${_resendSeconds.toString().padLeft(2, '0')}'
                          : 'Resend OTP',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
