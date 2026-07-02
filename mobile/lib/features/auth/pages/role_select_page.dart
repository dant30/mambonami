import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage> {
  String _selectedRole = 'buyer';

  final List<_RoleOption> _roles = const [
    _RoleOption(
      value: 'buyer',
      label: 'Buyer',
      description: 'Shop fresh produce and follow your orders.',
      icon: Icons.shopping_bag_outlined,
      accent: AppColors.buyerAccent,
    ),
    _RoleOption(
      value: 'farmer',
      label: 'Farmer',
      description: 'List harvests, receive orders, and manage payouts.',
      icon: Icons.agriculture_outlined,
      accent: AppColors.farmerAccent,
    ),
    _RoleOption(
      value: 'transport_provider',
      label: 'Transport',
      description: 'Accept bookings and deliver produce on schedule.',
      icon: Icons.local_shipping_outlined,
      accent: AppColors.providerAccent,
    ),
    _RoleOption(
      value: 'retailer',
      label: 'Retailer',
      description: 'Stock up for resale and grow your catalog.',
      icon: Icons.storefront_outlined,
      accent: AppColors.supportAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Choose your role'),
      body: AppScreen(
        useGradientBackground: true,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pick the role that best matches how you use Mambonami.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ..._roles.map((role) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RoleTile(
                    option: role,
                    selected: _selectedRole == role.value,
                    onTap: () => setState(() => _selectedRole = role.value),
                  ),
                )),
            const SizedBox(height: 8),
            CustomButton(
              onPressed: () => context.go(RoutePaths.success),
              label: 'Continue',
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => context.go(RoutePaths.login),
              icon: const Icon(Icons.login_outlined),
              label: const Text('Already have an account? Log in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOption {
  final String value;
  final String label;
  final String description;
  final IconData icon;
  final Color accent;

  const _RoleOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    required this.accent,
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
    final surface = selected
        ? option.accent.withValues(alpha: 0.10)
        : theme.colorScheme.surface.withValues(alpha: 0.9);

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? option.accent.withValues(alpha: 0.45)
                  : theme.colorScheme.outline.withValues(alpha: 0.7),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: option.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(option.icon, color: option.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                color: selected ? option.accent : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
