import 'package:flutter/material.dart';
import '../../../shared/widgets/app_logo.dart';
import 'auth_surface.dart';

class AuthPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;

  const AuthPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(height: 20),
          ] else ...[
            const AppLogo(size: 52, showWordmark: true),
            const SizedBox(height: 24),
          ],
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const AuthTrustStrip(),
        ],
      ),
    );
  }
}
