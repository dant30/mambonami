// mobile/lib/features/auth/pages/forgot_password_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../widgets/auth_surface.dart';

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
    _resendSeconds = 30;
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

  void _resetFlow() {
    setState(() {
      _codeSent = false;
      _showCodeEntry = false;
      _otpController.clear();
      _newPasswordController.clear();
      _resendSeconds = 0;
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
    setState(() {
      _showCodeEntry = true;
    });
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Reset Password'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordInitSuccess) {
            setState(() {
              _codeSent = true;
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
          return AppScreen(
            child: Form(
              key: _formKey,
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
                        Icons.lock_reset_rounded,
                        color: theme.colorScheme.primary,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _codeSent ? 'Secure code sent' : 'Forgot password?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _codeSent
                        ? 'A reset code has been sent. Enter it to choose a new password.'
                        : 'Enter your registered phone number and we will send a secure reset code via SMS.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AuthSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthStepBadge(
                          label: _codeSent
                              ? 'Step 2 of 2: Enter code'
                              : 'Step 1 of 2: Send reset code',
                          icon: _codeSent
                              ? Icons.password_outlined
                              : Icons.phone_iphone_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hintText: '+254 700 000 000',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          enabled: !_codeSent,
                          validator: (value) =>
                              value == null || value.trim().length < 10
                                  ? 'Enter a valid phone number'
                                  : null,
                        ),
                        if (_codeSent) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'A reset code has been sent to ${_phoneController.text.trim()}.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            onPressed: isLoading ? null : _enterCode,
                            label: 'Enter Code',
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _resendSeconds > 0
                                ? 'Resend code in $_resendSeconds seconds'
                                : 'Didn’t receive the code? Tap resend.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed:
                                isLoading || _resendSeconds > 0 ? null : _resendOTP,
                            child: Text(
                              _resendSeconds > 0
                                  ? 'Resend code ($_resendSeconds)'
                                  : 'Resend code',
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_showCodeEntry) ...[
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
                            const SizedBox(height: 18),
                            CustomButton(
                              onPressed: _verifyReset,
                              isLoading: isLoading,
                              label: 'Reset Password',
                              icon: const Icon(Icons.check_circle_outline),
                            ),
                          ],
                        ] else ...[
                          const SizedBox(height: 18),
                          CustomButton(
                            onPressed: _sendResetOTP,
                            isLoading: isLoading,
                            label: 'Send Reset Code',
                            icon: const Icon(Icons.sms_outlined),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed:
                        isLoading ? null : () => context.go(RoutePaths.login),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to login'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
