// mobile/lib/features/auth/pages/login_page.dart
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
      context.read<AuthBloc>().add(
            LoginEvent(
              _phoneController.text.trim(),
              _passwordController.text,
            ),
          );
    }
  }

  void _routeAuthenticated(AuthAuthenticated state) {
    if (state.role == 'farmer') {
      context.go(RoutePaths.farmerDashboard);
      return;
    }
    if (state.role == 'transport_provider') {
      context.go(RoutePaths.transportProviderDashboard);
      return;
    }
    context.go(RoutePaths.buyerDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Login'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _routeAuthenticated(state);
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
                  const AuthPageHeader(
                    title: 'Welcome back',
                    subtitle:
                        'Sign in to shop fresh produce, manage farm orders, or continue delivery work.',
                  ),
                  AuthSurface(
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value == null || value.trim().length < 10
                                  ? 'Enter a valid phone number'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          obscureText: _isPasswordHidden,
                          textInputAction: TextInputAction.done,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Required' : null,
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
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.go(RoutePaths.forgotPassword),
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomButton(
                          onPressed: _login,
                          isLoading: isLoading,
                          label: 'Login',
                          icon: const Icon(Icons.login_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed:
                        isLoading ? null : () => context.go(RoutePaths.register),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Create a Mambonami account'),
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
