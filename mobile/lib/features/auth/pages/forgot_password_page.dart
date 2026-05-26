import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../shared/widgets/custom_app_bar.dart';
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

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Reset Password'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordInitSuccess) {
            setState(() => _otpSent = true);
            CustomSnackbar.showSuccess(context, 'OTP sent to your phone');
          } else if (state is ForgotPasswordSuccess) {
            CustomSnackbar.showSuccess(context, 'Password reset successful. Please login.');
            context.go('/login');
          } else if (state is AuthError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v!.length < 10 ? 'Enter valid phone' : null,
                  ),
                  if (_otpSent) ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _otpController,
                      label: 'OTP Code',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: _verifyReset,
                      isLoading: isLoading,
                      label: 'Reset Password',
                    ),
                  ] else ...[
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: _sendResetOTP,
                      isLoading: isLoading,
                      label: 'Send Reset OTP',
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
