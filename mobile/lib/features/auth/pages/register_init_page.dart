// mobile/lib/features/auth/pages/register_init_page.dart
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

class RegisterInitPage extends StatefulWidget {
  const RegisterInitPage({super.key});

  @override
  State<RegisterInitPage> createState() => _RegisterInitPageState();
}

class _RegisterInitPageState extends State<RegisterInitPage> {
  final _phoneController = TextEditingController();
  String _selectedRole = 'buyer';
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _roles = [
    {'value': 'buyer', 'label': 'Buyer (Consumer)'},
    {'value': 'retailer', 'label': 'Retailer'},
    {'value': 'farmer', 'label': 'Farmer'},
    {'value': 'transport_provider', 'label': 'Transport Provider'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOTP() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(RegisterInitEvent(_phoneController.text.trim(), _selectedRole));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Register'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegisterInitSuccess) {
            context.go(
              RoutePaths.registerVerify,
              extra: {
                'phone': _phoneController.text.trim(),
                'role': _selectedRole,
              },
            );
          } else if (state is AuthError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthPageHeader(
                    title: 'Create your account',
                    subtitle: 'Enter your phone number and choose a role to receive a verification code.',
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
                          validator: (v) => v!.length < 10 ? 'Enter valid phone' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(labelText: 'I am a...'),
                          items: _roles.map((role) {
                            return DropdownMenuItem(value: role['value'], child: Text(role['label']!));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedRole = val ?? _selectedRole),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose the role that best matches how you will use the app.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          onPressed: _sendOTP,
                          isLoading: isLoading,
                          label: 'Send OTP',
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go(RoutePaths.login),
                          child: const Text('Already have an account? Login'),
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
