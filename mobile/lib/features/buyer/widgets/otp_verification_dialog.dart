// lib/features/buyer/widgets/otp_verification_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../blocs/trip/trip_bloc.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

/// Show this dialog at delivery: buyer reads code → driver enters here.
class OtpVerificationDialog extends StatefulWidget {
  final String orderId;
  final VoidCallback onSuccess;

  const OtpVerificationDialog({
    super.key,
    required this.orderId,
    required this.onSuccess,
  });

  @override
  State<OtpVerificationDialog> createState() =>
      _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  String _otp = '';
  bool _loading = false;
  String? _error;
  int _attemptsLeft = 3;

  final _defaultTheme = PinTheme(
    width: 58,
    height: 58,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
    ),
    textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary),
  );

  final _focusedTheme = PinTheme(
    width: 58,
    height: 58,
    decoration: BoxDecoration(
      color: AppColors.surfaceHighLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary, width: 2),
    ),
    textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary),
  );

  Future<void> _verify() async {
    if (_otp.length < 4) {
      setState(() => _error = 'Enter the 4-digit code');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      context.read<TripBloc>().add(
            VerifyDeliveryOtpEvent(
              orderId: widget.orderId,
              otp: _otp,
            ),
          );
      Navigator.of(context).pop();
      widget.onSuccess();
    } catch (e) {
      setState(() {
        _attemptsLeft--;
        _error = _attemptsLeft > 0
            ? 'Wrong code — $_attemptsLeft attempt${_attemptsLeft == 1 ? "" : "s"} left'
            : 'No more attempts. Contact support.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shield icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.shield_rounded,
                  color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),

            Text(
              'Enter Delivery OTP',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ask the buyer for the 4-digit code shown in their app.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 20),

            // Pinput OTP
            Pinput(
              length: 4,
              keyboardType: TextInputType.number,
              defaultPinTheme: _defaultTheme,
              focusedPinTheme: _focusedTheme,
              submittedPinTheme: _focusedTheme,
              onChanged: (v) => setState(() => _otp = v),
              onCompleted: (v) { _otp = v; _verify(); },
            ),

            // Error message
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],

            const SizedBox(height: 20),

            // Expiry note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.gold, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'OTP expires in 5 minutes. Escrow released after confirmation.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _loading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.muted,
                      side: BorderSide(
                          color:
                              AppColors.muted.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: 'Verify OTP',
                    isLoading: _loading,
                    onPressed: _attemptsLeft > 0 ? _verify : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}