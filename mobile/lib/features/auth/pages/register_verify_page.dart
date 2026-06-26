// mobile/lib/features/auth/pages/register_verify_page.dart
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
  final _licensePlateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  String _selectedVehicleType = 'motorcycle';
  static const List<String> _vehicleTypes = [
    'motorcycle',
    'pickup',
    'lorry',
    'van',
  ];

  @override
  void dispose() {
    _otpController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _farmGpsController.dispose();
    _mpesaController.dispose();
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
            vehicleType: widget.role == 'transport_provider' ? _selectedVehicleType : null,
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
            final role = state.role;
            if (role == 'farmer') {
              context.go(RoutePaths.farmerDashboard);
            } else if (role == 'transport_provider') {
              context.go(RoutePaths.transportProviderDashboard);
            } else {
              // buyers and retailers
              context.go(RoutePaths.buyerDashboard);
            }
          } else if (state is AuthError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final summaryCard = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone: ${widget.phone}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Role: ${widget.role.replaceAll('_', ' ')}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthPageHeader(
                    title: 'Verify your account',
                    subtitle: 'Enter the OTP sent to your phone and complete the form below to finish registration.',
                    leading: summaryCard,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [                  CustomTextField(
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
                    obscureText: _isPasswordHidden,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordHidden ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: _isConfirmPasswordHidden,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordHidden ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() {
                        _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                      }),
                    ),
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
                    const SizedBox(height: 20),
                    Text(
                      'Farmer details',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 20),
                    Text(
                      'Transport provider details',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        filled: true,
                      ),
                      items: _vehicleTypes
                          .map((type) => DropdownMenuItem(value: type, child: Text(type[0].toUpperCase() + type.substring(1))))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedVehicleType = value;
                          });
                        }
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Required for transport providers' : null,
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
                    label: 'Complete registration',
                  ),
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
