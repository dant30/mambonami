// mobile/lib/features/auth/pages/role_select_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../../config/role_routes.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/custom_button.dart';

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage>
    with SingleTickerProviderStateMixin {
  String _selectedRole = AppRole.farmer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _continue() {
    HapticFeedback.selectionClick();
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          useGradientBackground: true,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: _BackButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.go(RoutePaths.welcome);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Header with gradient background
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.hero,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose your role',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'How will you use MAMBONAMI?',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Role tiles
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: _roles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final role = _roles[index];
                      final isSelected = _selectedRole == role.value;
                      return _RoleTile(
                        option: role,
                        selected: isSelected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedRole = role.value);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Continue button
                CustomButton(
                  onPressed: _continue,
                  label: 'Continue',
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
                const SizedBox(height: 12),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.go(RoutePaths.login);
                      },
                      child: Text(
                        'Log in',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Footer note
                Center(
                  child: Text(
                    'You can add more roles later in settings',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
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
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.arrow_back_rounded,
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
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = selected
        ? option.accent.withValues(alpha: 0.58)
        : (isDark
            ? theme.colorScheme.outline.withValues(alpha: 0.3)
            : Colors.transparent);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: option.accent.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: selected
            ? Colors.white
            : (isDark
                ? theme.colorScheme.surfaceContainerHighest
                : Colors.white),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: option.accent.withValues(alpha: 0.08),
          highlightColor: option.accent.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: option.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: selected
                        ? Border.all(
                            color: option.accent.withValues(alpha: 0.2),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Image.asset(
                    option.asset,
                    fit: BoxFit.contain,
                    colorBlendMode: selected ? null : BlendMode.saturation,
                    color: selected ? null : Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: selected ? AppColors.dark : AppColors.dark,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: selected
                              ? AppColors.muted
                              : AppColors.muted.withValues(alpha: 0.7),
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? option.accent : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? option.accent
                          : AppColors.muted.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}