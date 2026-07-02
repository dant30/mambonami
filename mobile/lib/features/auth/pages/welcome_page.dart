import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_screen.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/app_logo.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppScreen(
        useGradientBackground: true,
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 1),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.16),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: const AppLogo(size: 92),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Mambonami',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Buy fresh produce, grow your business, and move goods with trusted local delivery.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                children: [
                  _WelcomeFeature(
                    icon: Icons.eco_outlined,
                    title: 'Fresh from local farms',
                    subtitle: 'Discover seasonal produce at fair prices.',
                  ),
                  const SizedBox(height: 12),
                  _WelcomeFeature(
                    icon: Icons.local_shipping_outlined,
                    title: 'Reliable delivery routes',
                    subtitle: 'Track pickups and drop-offs in real time.',
                  ),
                  const SizedBox(height: 12),
                  _WelcomeFeature(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Fast payments and payouts',
                    subtitle: 'Simple checkout and easy earnings for growers.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: () => context.go(RoutePaths.otp, extra: {'phone': ''}),
              label: 'Continue with phone',
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            const SizedBox(height: 12),
            CustomButton(
              onPressed: () => context.go(RoutePaths.roleSelect),
              label: 'Choose your role',
              outlined: true,
              icon: const Icon(Icons.person_add_alt_1_outlined),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

class _WelcomeFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _WelcomeFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
