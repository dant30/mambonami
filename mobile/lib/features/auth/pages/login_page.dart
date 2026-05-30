// mobile/lib/features/auth/pages/login_page.dart
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordHidden = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginEvent(_phoneController.text.trim(), _passwordController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Login'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final role = state.role;
            if (role == 'farmer') {
              context.go(RoutePaths.farmerDashboard);
            } else if (role == 'transport_provider') {
              context.go(RoutePaths.transportProviderDashboard);
            } else {
              context.go(RoutePaths.buyerDashboard);
            }
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
                  const AuthPageHeader(
                    title: 'Welcome back',
                    subtitle: 'Sign in with your phone number to continue to your account.',
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
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: _isPasswordHidden,
                          textInputAction: TextInputAction.done,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () => setState(() {
                              _isPasswordHidden = !_isPasswordHidden;
                            }),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          onPressed: _login,
                          isLoading: isLoading,
                          label: 'Login',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => context.go(RoutePaths.forgotPassword),
                              child: const Text('Forgot password?'),
                            ),
                            TextButton(
                              onPressed: () => context.go(RoutePaths.register),
                              child: const Text('Create account'),
                            ),
                          ],
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
