// mobile/lib/features/support/widgets/faq_item.dart

import 'package:flutter/material.dart';

import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_snackbar.dart';

class SupportFaqItem extends StatelessWidget {
  final String question;

  const SupportFaqItem({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        title: Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.dark,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        onTap: () {
          CustomSnackbar.showInfo(
            context,
            'FAQ answer coming soon!',
          );
        },
      ),
    );
  }
}
