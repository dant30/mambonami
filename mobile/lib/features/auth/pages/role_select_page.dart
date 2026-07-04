import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/role_routes.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage> {
  String _selectedRole = AppRole.farmer;

  static const List<_RoleOption> _roles = [
    _RoleOption(
      value: AppRole.farmer,
      label: 'Farmer',
      description: 'Sell fresh produce directly to buyers across Kenya.',
      asset: 'assets/icons/farmer_icon.png',
      accent: AppColors.primary,
    ),
    _RoleOption(
      value: AppRole.buyer,
      label: 'Buyer / Consumer',
      description: 'Buy fresh farm produce delivered to your door.',
      asset: 'assets/icons/buyer_icon.png',
      accent: AppColors.secondary,
    ),
    _RoleOption(
      value: AppRole.transportProvider,
      label: 'Transport Provider',
      description: 'Deliver orders and earn daily income.',
      asset: 'assets/icons/transport_icon.png',
      accent: AppColors.warning,
    ),
    _RoleOption(
      value: AppRole.retailer,
      label: 'Retailer / Business',
      description: 'Bulk orders for your grocery or restaurant.',
      asset: 'assets/icons/secure_payment_icon.png',
      accent: AppColors.supportAccent,
    ),
  ];

  void _continue() {
    context.go(
      AppRole.registrationPathFor(_selectedRole),
      extra: {'role': _selectedRole},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppScreen(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _BackButton(onPressed: () => context.go(RoutePaths.welcome)),
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
                onPressed: _continue,
                label: 'Continue',
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => context.go(RoutePaths.login),
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
  }
}

class _RoleOption {
  final String value;
  final String label;
  final String description;
  final String asset;
  final Color accent;

  const _RoleOption({
    required this.value,
    required this.label,
    required this.description,
    required this.asset,
    required this.accent,
  });
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

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
    final borderColor =
        selected ? option.accent.withValues(alpha: 0.58) : Colors.transparent;

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
                color: Colors.black.withValues(alpha: 0.06),
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
                  color: option.accent.withValues(alpha: 0.10),
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.dark,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                color: selected ? option.accent : AppColors.muted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
