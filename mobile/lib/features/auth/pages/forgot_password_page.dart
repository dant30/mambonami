// mobile/lib/features/auth/pages/forgot_password_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _codeSent = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _phoneController.dispose();
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
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
            } else if (state is AuthError) {
              CustomSnackbar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button (matches prototype)
                      const BackButton(),
                      const SizedBox(height: 24),

                      // Icon tile
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: AppRadius.lg,
                        ),
                        child: Icon(
                          Icons.shield_rounded,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title & subtitle
                      Text(
                        _codeSent ? 'Code Sent!' : 'Forgot Password?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _codeSent
                            ? 'A 4-digit reset code was sent to $_maskedPhone. Check your SMS.'
                            : "Enter your registered phone number. We'll send a reset code via SMS.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),

                      if (!_codeSent) ...[
                        // ── Phone input ──
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: '+254 700 000 000',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(
                            Icons.phone_rounded,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter phone number' : null,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          label: 'Send Reset Code',
                          onPressed: _sendResetOTP,
                          isLoading: isLoading,
                        ),
                      ] else ...[
                        // ── Code Sent confirmation ──
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.send_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Code Sent!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: 'A 4-digit reset code was sent to ',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 13,
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
                              const SizedBox(height: 24),
                              CustomButton(
                                label: 'Enter Code',
                                onPressed: () => context.go(
                                  RoutePaths.otp,
                                  extra: {
                                    'phone': _phoneController.text.trim(),
                                    'mode': 'forgot_password',
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _resendSeconds == 0 ? _resendOTP : null,
                                child: Text(
                                  _resendSeconds > 0
                                      ? 'Resend in 00:${_resendSeconds.toString().padLeft(2, '0')}'
                                      : 'Resend code',
                                  style: TextStyle(
                                    color: _resendSeconds == 0
                                        ? theme.colorScheme.secondary
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}