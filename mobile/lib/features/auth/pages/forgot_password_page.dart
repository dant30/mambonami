import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

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
    if (_otpController.text.trim().length == 4 && _newPasswordController.text.trim().length >= 6) {
      context.read<AuthBloc>().add(ForgotPasswordVerifyEvent(
            phone: _phoneController.text.trim(),
            otp: _otpController.text.trim(),
            newPassword: _newPasswordController.text,
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid OTP and password (min 6 chars)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordInitSuccess) {
            setState(() => _otpSent = true);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent to your phone')));
          } else if (state is ForgotPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successful. Please login.')));
            Navigator.pop(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.length < 10 ? 'Enter valid phone' : null,
                ),
                const SizedBox(height: 16),
                if (_otpSent) ...[
                  CustomTextField(
                    controller: _otpController,
                    label: 'OTP Code',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.length != 4 ? 'Enter 4-digit OTP' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(onPressed: _verifyReset, child: const Text('Reset Password')),
                ] else ...[
                  const SizedBox(height: 24),
                  CustomButton(onPressed: _sendResetOTP, child: const Text('Send Reset OTP')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
