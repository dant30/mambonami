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
import '../widgets/auth_page_header.dart';
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
  bool _otpSent = false;
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
      _otpSent = false;
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
    return Scaffold(
      appBar: const CustomAppBar(title: 'Reset Password'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordInitSuccess) {
            setState(() {
              _otpSent = true;
              _startResendTimer();
            });
            CustomSnackbar.showSuccess(
              context,
              'OTP sent to your phone. Check your messages.',
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
                  AuthPageHeader(
                    title: 'Reset password',
                    subtitle: _otpSent
                        ? 'Verify the OTP and choose a new password for your account.'
                        : 'Enter your phone number and we will send a secure reset OTP.',
                  ),
                  AuthSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthStepBadge(
                          label: _otpSent
                              ? 'Step 2 of 2: Verify OTP'
                              : 'Step 1 of 2: Confirm phone',
                          icon: _otpSent
                              ? Icons.password_outlined
                              : Icons.phone_iphone_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          enabled: !_otpSent,
                          validator: (value) =>
                              value == null || value.trim().length < 10
                                  ? 'Enter a valid phone number'
                                  : null,
                        ),
                        if (_otpSent) ...[
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _otpController,
                            label: 'OTP Code',
                            prefixIcon:
                                const Icon(Icons.pin_outlined),
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
                          const SizedBox(height: 12),
                          Text(
                            _resendSeconds > 0
                                ? 'Resend OTP available in $_resendSeconds seconds'
                                : 'You can resend the OTP if it did not arrive.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 18),
                          CustomButton(
                            onPressed: _verifyReset,
                            isLoading: isLoading,
                            label: 'Reset Password',
                            icon: const Icon(Icons.check_circle_outline),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            children: [
                              TextButton(
                                onPressed:
                                    isLoading || _resendSeconds > 0
                                        ? null
                                        : _resendOTP,
                                child: Text(
                                  _resendSeconds > 0
                                      ? 'Resend OTP ($_resendSeconds)'
                                      : 'Resend OTP',
                                ),
                              ),
                              TextButton(
                                onPressed: isLoading ? null : _resetFlow,
                                child: const Text('Use different phone'),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 18),
                          CustomButton(
                            onPressed: _sendResetOTP,
                            isLoading: isLoading,
                            label: 'Send Reset OTP',
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
