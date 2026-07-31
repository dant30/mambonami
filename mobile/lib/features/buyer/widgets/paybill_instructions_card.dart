// lib/features/buyer/widgets/paybill_instructions_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';

class PaybillInstructionsCard extends StatefulWidget {
  final String paybillNumber;
  final String accountNumber;
  final double amount;

  const PaybillInstructionsCard({
    super.key,
    required this.paybillNumber,
    required this.accountNumber,
    required this.amount,
  });

  @override
  State<PaybillInstructionsCard> createState() =>
      _PaybillInstructionsCardState();
}

class _PaybillInstructionsCardState
    extends State<PaybillInstructionsCard> {
  bool _paybillCopied = false;
  bool _accountCopied = false;

  Future<void> _copy(String text, bool isPaybill) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() {
      if (isPaybill) {
        _paybillCopied = true;
      } else {
        _accountCopied = true;
      }
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _paybillCopied = false;
        _accountCopied = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Open your M-Pesa app or dial *334#',
      'Select Lipa na M-Pesa → Pay Bill',
      'Enter Business Number: ${widget.paybillNumber}',
      'Enter Account Number: ${widget.accountNumber}',
      'Enter Amount: KES ${widget.amount.toStringAsFixed(0)}',
      'Enter your M-Pesa PIN and confirm',
    ];

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shield_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pay via M-Pesa',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                          )),
                  Text('Funds held securely in escrow',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.muted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Numbered steps
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FOLLOW THESE STEPS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.muted,
                      ),
                ),
                const SizedBox(height: 12),
                ...steps.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.dark),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Copyable paybill + account numbers
          Row(
            children: [
              Expanded(
                child: _CopyCard(
                  label: 'Paybill Number',
                  value: widget.paybillNumber,
                  copied: _paybillCopied,
                  onCopy: () => _copy(widget.paybillNumber, true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CopyCard(
                  label: 'Account Number',
                  value: widget.accountNumber,
                  copied: _accountCopied,
                  onCopy: () => _copy(widget.accountNumber, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CopyCard extends StatelessWidget {
  final String label;
  final String value;
  final bool copied;
  final VoidCallback onCopy;

  const _CopyCard({
    required this.label,
    required this.value,
    required this.copied,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onCopy,
                  child: Icon(
                    copied
                        ? Icons.check_circle_rounded
                        : Icons.copy_rounded,
                    size: 16,
                    color: copied ? AppColors.success : AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}