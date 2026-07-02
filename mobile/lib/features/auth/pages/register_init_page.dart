// mobile/lib/features/auth/pages/register_init_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../widgets/auth_page_header.dart';
import '../widgets/auth_surface.dart';

class RegisterInitPage extends StatefulWidget {
  const RegisterInitPage({super.key});

  @override
  State<RegisterInitPage> createState() => _RegisterInitPageState();
}

class _RegisterInitPageState extends State<RegisterInitPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'buyer';

  static const List<_RoleOption> _roles = [
    _RoleOption(
      value: 'buyer',
      label: 'Buyer',
      description: 'Shop fresh products and track deliveries.',
      icon: Icons.shopping_bag_outlined,
      color: AppColors.buyerAccent,
    ),
    _RoleOption(
      value: 'retailer',
      label: 'Retailer',
      description: 'Buy produce for resale and repeat supply.',
      icon: Icons.storefront_outlined,
      color: AppColors.supportAccent,
    ),
    _RoleOption(
      value: 'farmer',
      label: 'Farmer',
      description: 'List harvests and manage incoming orders.',
      icon: Icons.agriculture_outlined,
      color: AppColors.farmerAccent,
    ),
    _RoleOption(
      value: 'transport_provider',
      label: 'Transport',
      description: 'Claim pickups and complete deliveries.',
      icon: Icons.local_shipping_outlined,
      color: AppColors.providerAccent,
    ),
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOTP() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterInitEvent(_phoneController.text.trim(), _selectedRole),
          );
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

          return AppScreen(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthPageHeader(
                    title: 'Create your account',
                    subtitle:
                        'Choose how you use Mambonami, then verify your phone number.',
                  ),
                  AuthSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hintText: '07XXXXXXXX',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          validator: (value) =>
                              value == null || value.trim().length < 10
                                  ? 'Enter a valid phone number'
                                  : null,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Account type',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),
                        ..._roles.map(
                          (role) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RoleTile(
                              option: role,
                              selected: _selectedRole == role.value,
                              onTap: () =>
                                  setState(() => _selectedRole = role.value),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          onPressed: _sendOTP,
                          isLoading: isLoading,
                          label: 'Send OTP',
                          icon: const Icon(Icons.sms_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => context.go(RoutePaths.login),
                    icon: const Icon(Icons.login_outlined),
                    label: const Text('Already have an account? Login'),
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

class _RoleOption {
  final String value;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const _RoleOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _RoleTile extends StatelessWidget {
  final _RoleOption option;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? option.color.withValues(alpha: 0.12)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? option.color
                  : theme.colorScheme.outline.withValues(alpha: 0.72),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: option.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(option.icon, color: option.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked_outlined,
                color: selected ? option.color : theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
