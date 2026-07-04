// mobile/lib/features/auth/pages/register_init_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../config/role_routes.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../widgets/auth_surface.dart';

class RegisterInitPage extends StatefulWidget {
  final String? initialRole;

  const RegisterInitPage({super.key, this.initialRole});

  @override
  State<RegisterInitPage> createState() => _RegisterInitPageState();
}

class _RegisterInitPageState extends State<RegisterInitPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? AppRole.buyer;
  }

  static const List<_RoleOption> _roles = [
    _RoleOption(
      value: AppRole.buyer,
      label: 'Buyer',
      description: 'Shop fresh products and track deliveries.',
      icon: Icons.shopping_bag_outlined,
      color: AppColors.buyerAccent,
    ),
    _RoleOption(
      value: AppRole.retailer,
      label: 'Retailer',
      description: 'Buy produce for resale and repeat supply.',
      icon: Icons.storefront_outlined,
      color: AppColors.supportAccent,
    ),
    _RoleOption(
      value: AppRole.farmer,
      label: 'Farmer',
      description: 'List harvests and manage incoming orders.',
      icon: Icons.agriculture_outlined,
      color: AppColors.farmerAccent,
    ),
    _RoleOption(
      value: AppRole.transportProvider,
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

  String get _pageTitle {
    switch (_selectedRole) {
      case AppRole.farmer:
        return 'Farmer registration';
      case AppRole.retailer:
        return 'Retailer registration';
      case AppRole.transportProvider:
        return 'Transport registration';
      case AppRole.buyer:
      default:
        return 'Buyer registration';
    }
  }

  String get _roleIconAsset {
    switch (_selectedRole) {
      case AppRole.farmer:
        return 'assets/icons/farmer_icon.png';
      case AppRole.transportProvider:
        return 'assets/icons/transport_icon.png';
      case AppRole.retailer:
        return 'assets/icons/secure_payment_icon.png';
      case AppRole.buyer:
      default:
        return 'assets/icons/buyer_icon.png';
    }
  }

  String get _roleSubtitle {
    switch (_selectedRole) {
      case AppRole.farmer:
        return 'Set up your farm profile, add your phone, and verify access to farmer tools.';
      case AppRole.transportProvider:
        return 'Set up your transport profile, verify your phone, and start accepting orders.';
      case AppRole.retailer:
        return 'Set up your retailer account and begin sourcing fresh produce.';
      case AppRole.buyer:
      default:
        return 'Set up your buyer account and verify your phone number.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
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

          return SafeArea(
            child: AppScreen(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _AuthBackButton(
                      onPressed: () => context.go(RoutePaths.roleSelect),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighLight,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Image.asset(_roleIconAsset, fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pageTitle,
                              style:
                                  theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.dark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _roleSubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  AuthSurface(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthStepBadge(
                          label: 'Step 1 of 2: Phone and role',
                          icon: Icons.phone_iphone_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hintText: '+254 700 000 000',
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

class _AuthBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AuthBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHighLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
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
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
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
                  borderRadius: BorderRadius.circular(14),
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
