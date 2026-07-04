import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _codeSent = false;
  bool _showCodeEntry = false;
  bool _isPasswordHidden = true;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 45;
    _resendTimer?.cancel();
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

  void _sendResetOTP() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            ForgotPasswordInitEvent(_phoneController.text.trim()),
          );
    }
  }

  void _enterCode() {
    setState(() => _showCodeEntry = true);
  }

  void _verifyReset() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            ForgotPasswordVerifyEvent(
              phone: _phoneController.text.trim(),
              otp: _otpController.text.trim(),
              newPassword: _newPasswordController.text,
            ),
          );
    }
  }

  void _resendOTP() {
    if (_resendSeconds == 0) {
      _sendResetOTP();
    }
  }

  String get _maskedPhone {
    final phone = _phoneController.text.trim();
    if (phone.length < 7) return phone.isEmpty ? 'your phone' : phone;
    return '${phone.substring(0, 4)} 7** *** ${phone.substring(phone.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordInitSuccess) {
            setState(() {
              _codeSent = true;
              _showCodeEntry = false;
              _startResendTimer();
            });
            CustomSnackbar.showSuccess(
              context,
              'Reset code sent. Check your phone.',
            );
          } else if (state is ForgotPasswordSuccess) {
            CustomSnackbar.showSuccess(
              context,
              'Password reset successful. Please login.',
            );
            context.go(RoutePaths.login);
          } else if (state is AuthError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: AppScreen(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Form(
                key: _formKey,
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
                    if (!_codeSent || _showCodeEntry) ...[
                      _AuthIconTile(
                        icon: _showCodeEntry
                            ? Icons.password_outlined
                            : Icons.shield_outlined,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showCodeEntry ? 'Enter reset code' : 'Forgot Password?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.dark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _showCodeEntry
                            ? 'Enter the OTP and choose a new password.'
                            : "Enter your registered phone number. We'll send a reset code via SMS.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    if (!_codeSent) ...[
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hintText: '+254 700 000 000',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        validator: (value) =>
                            value == null || value.trim().length < 10
                                ? 'Enter a valid phone number'
                                : null,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        onPressed: _sendResetOTP,
                        isLoading: isLoading,
                        label: 'Send Reset Code',
                        icon: const Icon(Icons.sms_outlined),
                      ),
                    ] else if (!_showCodeEntry) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceHighLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send_rounded,
                                color: AppColors.primary,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Code Sent!',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.dark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'A 4-digit reset code was sent to $_maskedPhone. Check your SMS.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              onPressed: isLoading ? null : _enterCode,
                              label: 'Enter Code',
                              icon: const Icon(Icons.arrow_forward_rounded),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: isLoading || _resendSeconds > 0
                                  ? null
                                  : _resendOTP,
                              child: Text(
                                _resendSeconds > 0
                                    ? 'Resend in 00:${_resendSeconds.toString().padLeft(2, '0')}'
                                    : 'Resend code',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      CustomTextField(
                        controller: _otpController,
                        label: 'OTP Code',
                        prefixIcon: const Icon(Icons.pin_outlined),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                        validator: (value) =>
                            value == null || value.trim().length != 4
                                ? 'Enter 4-digit OTP'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _newPasswordController,
                        label: 'New Password',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        obscureText: _isPasswordHidden,
                        textInputAction: TextInputAction.done,
                        validator: (value) =>
                            value == null || value.length < 6
                                ? 'Min 6 characters'
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
                      const SizedBox(height: 24),
                      CustomButton(
                        onPressed: _verifyReset,
                        isLoading: isLoading,
                        label: 'Reset Password',
                        icon: const Icon(Icons.check_circle_outline),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed:
                            isLoading || _resendSeconds > 0 ? null : _resendOTP,
                        child: Text(
                          _resendSeconds > 0
                              ? 'Resend in 00:${_resendSeconds.toString().padLeft(2, '0')}'
                              : 'Resend code',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
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
