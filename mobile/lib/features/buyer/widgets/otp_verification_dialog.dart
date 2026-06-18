// mobile/lib/features/buyer/widgets/otp_verification_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/widgets/otp_input_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../blocs/trip/trip_bloc.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.shield_outlined, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'Confirm Delivery',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 4-digit OTP shown by your delivery provider',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OtpInputField(
              length: 4,
              controller: _otpController,
              onCompleted: (otp) {
                _verifyOTP(otp);
              },
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _error,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
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
      VerifyOTPEvent(tripUuid: widget.tripUuid, otp: otp),
    );
  }
}