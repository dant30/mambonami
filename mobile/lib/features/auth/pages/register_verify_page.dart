// OTP + details
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';

class RegisterVerifyPage extends StatefulWidget {
  final String phone;
  final String role;

  const RegisterVerifyPage({
    super.key,
    required this.phone,
    required this.role,
  });

  @override
  State<RegisterVerifyPage> createState() => _RegisterVerifyPageState();
}

class _RegisterVerifyPageState extends State<RegisterVerifyPage> {
  final _otpController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _farmGpsController = TextEditingController();
  final _mpesaController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _farmGpsController.dispose();
    _mpesaController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _verify() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(RegisterVerifyEvent(
            phone: widget.phone,
            otp: _otpController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            role: widget.role,
            farmGps: widget.role == 'farmer' ? _farmGpsController.text.trim() : null,
            mpesaNumber: widget.role == 'farmer' ? _mpesaController.text.trim() : null,
            vehicleType: widget.role == 'transport_provider' ? _vehicleTypeController.text.trim() : null,
            licensePlate: widget.role == 'transport_provider' ? _licensePlateController.text.trim() : null,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Verify OTP'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/${state.role}');
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
                children: [
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _otpController,
                    label: 'OTP Code',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v!.length != 4 ? 'Enter 4-digit OTP' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _usernameController,
                    label: 'Username',
                    textInputAction: TextInputAction.next,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email (optional)',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v != null && v.isNotEmpty && !v.contains('@')) {
                        return 'Enter valid email';
                      }
                      return null;
                    },
                  ),
                  if (widget.role == 'farmer') ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _farmGpsController,
                      label: 'Farm GPS (lat,lng)',
                      textInputAction: TextInputAction.next,
                      validator: (v) => v!.isEmpty ? 'Required for farmers' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _mpesaController,
                      label: 'M-Pesa Number',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (v) => v!.isEmpty ? 'Required for farmers' : null,
                    ),
                  ],
                  if (widget.role == 'transport_provider') ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _vehicleTypeController,
                      label: 'Vehicle Type (motorcycle/pickup/lorry/van)',
                      textInputAction: TextInputAction.next,
                      validator: (v) => v!.isEmpty ? 'Required for transport providers' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _licensePlateController,
                      label: 'License Plate',
                      textInputAction: TextInputAction.done,
                      validator: (v) => v!.isEmpty ? 'Required for transport providers' : null,
                    ),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    onPressed: _verify,
                    isLoading: isLoading,
                    label: 'Verify & Register',
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
