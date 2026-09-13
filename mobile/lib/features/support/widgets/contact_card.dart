// mobile/lib/features/support/widgets/contact_card.dart

import 'package:flutter/material.dart';

import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';

class SupportContactCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const SupportContactCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
