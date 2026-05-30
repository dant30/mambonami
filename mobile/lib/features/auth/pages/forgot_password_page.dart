// mobile/lib/features/auth/pages/forgot_password_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../widgets/auth_page_header.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';

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
  bool _otpSent = false;
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
      _otpSent = false;
      _otpController.clear();
      _newPasswordController.clear();
      _resendSeconds = 0;
    });
  }

  void _sendResetOTP() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(ForgotPasswordInitEvent(_phoneController.text.trim()));
    }
  }

  void _verifyReset() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(ForgotPasswordVerifyEvent(
            phone: _phoneController.text.trim(),
            otp: _otpController.text.trim(),
            newPassword: _newPasswordController.text,
          ));
    }
  }

  void _resendOTP() {
    if (_resendSeconds == 0) {
      _sendResetOTP();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Reset Password'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordInitSuccess) {
            setState(() {
              _otpSent = true;
              _startResendTimer();
            });
            CustomSnackbar.showSuccess(context, 'OTP sent to your phone. Check your messages.');
          } else if (state is ForgotPasswordSuccess) {
            CustomSnackbar.showSuccess(context, 'Password reset successful. Please login.');
            context.go(RoutePaths.login);
          } else if (state is AuthError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AuthPageHeader(
                    title: 'Reset Password',
                    subtitle: _otpSent
                        ? 'Enter the OTP sent to your phone and choose a new password.'
                        : 'Enter your phone number to receive a password reset OTP.',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    enabled: !_otpSent,
                    validator: (v) => v!.length < 10 ? 'Enter valid phone' : null,
                  ),
                  if (_otpSent) ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _otpController,
                      label: 'OTP Code',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      validator: (v) => v!.length != 4 ? 'Enter 4-digit OTP' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                    ),
                    if (_resendSeconds > 0) ...[
                      Text(
                        'Resend OTP available in $_resendSeconds seconds',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      Text(
                        'You can resend the OTP if you did not receive it.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: _verifyReset,
                      isLoading: isLoading,
                      label: 'Reset Password',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: isLoading || _resendSeconds > 0 ? null : _resendOTP,
                          child: Text(
                            _resendSeconds > 0 ? 'Resend OTP ($_resendSeconds)' : 'Resend OTP',
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: isLoading ? null : _resetFlow,
                          child: const Text('Use different phone'),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: _sendResetOTP,
                      isLoading: isLoading,
                      label: 'Send Reset OTP',
                    ),
                    const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go(RoutePaths.login),
                          child: const Text('Back to login'),
                        ),
                  ],
                      ],
                    ),
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
