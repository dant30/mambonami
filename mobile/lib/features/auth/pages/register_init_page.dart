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
      value: AppRole.farmer,
      label: 'Farmer',
      description: 'Sell fresh produce directly to buyers across Kenya.',
      icon: Icons.agriculture_outlined,
      asset: 'assets/icons/farmer_icon.png',
      color: AppColors.primary,
    ),
    _RoleOption(
      value: AppRole.buyer,
      label: 'Buyer / Consumer',
      description: 'Buy fresh farm produce delivered to your door.',
      icon: Icons.shopping_bag_outlined,
      asset: 'assets/icons/buyer_icon.png',
      color: AppColors.secondary,
    ),
    _RoleOption(
      value: AppRole.transportProvider,
      label: 'Transport Provider',
      description: 'Deliver orders and earn daily income.',
      icon: Icons.local_shipping_outlined,
      asset: 'assets/icons/transport_icon.png',
      color: AppColors.providerAccent,
    ),
    _RoleOption(
      value: AppRole.retailer,
      label: 'Retailer / Business',
      description: 'Bulk orders for your grocery or restaurant.',
      icon: Icons.storefront_outlined,
      asset: 'assets/icons/secure_payment_icon.png',
      color: AppColors.supportAccent,
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
                    Text(
                      'Choose your role',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.dark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How will you use MAMBONAMI?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _roles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final role = _roles[index];
                          return _RoleTile(
                            option: role,
                            selected: _selectedRole == role.value,
                            onTap: () => setState(() => _selectedRole = role.value),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    CustomButton(
                      onPressed: _sendOTP,
                      isLoading: isLoading,
                      label: 'Continue',
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => context.go(RoutePaths.login),
                      icon: const Icon(Icons.login_outlined),
                      label: const Text('Already have an account? Log in'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You can add more roles later in settings',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
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
  final String asset;
  final Color color;

  const _RoleOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    required this.asset,
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
    final borderColor = selected ? option.color.withOpacity(0.58) : Colors.transparent;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: option.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(option.asset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.dark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? option.color : AppColors.muted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
