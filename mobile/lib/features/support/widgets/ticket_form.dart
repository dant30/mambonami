// mobile/lib/features/support/widgets/ticket_form.dart

import 'package:flutter/material.dart';

import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_snackbar.dart';

class SupportTicketForm extends StatefulWidget {
  const SupportTicketForm({super.key});

  @override
  State<SupportTicketForm> createState() => _SupportTicketFormState();
}

class _SupportTicketFormState extends State<SupportTicketForm> {
  String _issueType = 'Payment / Escrow';
  final TextEditingController _messageController = TextEditingController();
  bool _submitted = false;
  bool _isSubmitting = false;

  final List<String> _issueTypes = [
    'Payment / Escrow',
    'Order dispute',
    'App bug',
    'Account issue',
    'Other',
  ];

  Future<void> _submitTicket() async {
    if (_messageController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please describe your issue');
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _submitted = true;
      _messageController.clear();
    });

    CustomSnackbar.showSuccess(context, 'Ticket submitted successfully!');
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit a Ticket',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Our team will respond within 24 hours',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _issueType,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.inputDark : AppColors.inputLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            items: _issueTypes.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Text(
                  t,
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (v) => setState(() => _issueType = v ?? _issueType),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe your issue in detail...',
              hintStyle: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
              filled: true,
              fillColor: isDark ? AppColors.inputDark : AppColors.inputLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_submitted)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '✓ Ticket submitted!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            CustomButton(
              label: _isSubmitting ? 'Submitting...' : 'Submit Ticket',
              isLoading: _isSubmitting,
              onPressed: _submitTicket,
            ),
        ],
      ),
    );
  }
}
