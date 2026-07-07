// mobile/lib/features/buyer/widgets/otp_verification_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/trip/trip_bloc.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
import '../../../shared/widgets/otp_input_field.dart';
import '../../../shared/widgets/custom_button.dart';

class OTPVerificationDialog extends StatefulWidget {
  final String tripUuid;
  final Function({bool success, String? message}) onComplete;

  const OTPVerificationDialog({
    super.key,
    required this.tripUuid,
    required this.onComplete,
  });

  @override
  State<OTPVerificationDialog> createState() => _OTPVerificationDialogState();
}

class _OTPVerificationDialogState extends State<OTPVerificationDialog> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.extraLarge),
      backgroundColor: theme.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Shield icon
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Confirm Delivery',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 4-digit OTP shown by your delivery provider',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OtpInputField(
              length: 4,
              controller: _otpController,
              onCompleted: (otp) => _verifyOTP(otp),
              fieldWidth: 60,
              spacing: 12,
              inputDecorationBuilder: (context, child) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.medium,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: child,
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _error,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.muted,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    label: 'Verify OTP',
                    isLoading: _isLoading,
                    onPressed: () {
                      final otp = _otpController.text.trim();
                      if (otp.length == 4) {
                        _verifyOTP(otp);
                      } else {
                        setState(() => _error = 'Please enter the 4-digit OTP');
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _verifyOTP(String otp) {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    context.read<TripBloc>().add(
          VerifyOtpEvent(widget.tripUuid, otp),
        );
    // Listen for success/failure via TripBloc listener – but we'll let parent handle it.
    // We can also use a BlocListener at a higher level.
  }
}