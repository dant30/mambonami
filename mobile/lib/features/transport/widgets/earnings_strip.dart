// mobile/lib/features/transport/widgets/earnings_strip.dart
import 'package:flutter/material.dart';
import '../../../shared/themes/app_colors.dart';

class EarningsAnalyticsStrip extends StatelessWidget {
  final double todayEarnings;
  final int completedTrips;
  final double pendingPayout;
  final double earnings;
  final String? payoutError;

  const EarningsAnalyticsStrip({
    super.key,
    required this.todayEarnings,
    required this.completedTrips,
    required this.pendingPayout,
    required this.earnings,
    this.payoutError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earnings & Payouts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AnalyticsTile(
                label: 'Today',
                value: 'KES ${todayEarnings.toStringAsFixed(0)}',
                icon: Icons.today_rounded,
                accentColor: AppColors.providerAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnalyticsTile(
                label: 'Completed',
                value: completedTrips.toString(),
                icon: Icons.check_circle_rounded,
                accentColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AnalyticsTile(
                label: 'Pending payout',
                value: 'KES ${pendingPayout.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_outlined,
                accentColor: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.providerAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: AppColors.providerAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  payoutError != null
                      ? 'Live payout snapshot unavailable. Showing fallback trip estimate for now.'
                      : 'Backend payout snapshot: KES ${earnings.toStringAsFixed(0)} · pending disbursement is ${pendingPayout.toStringAsFixed(0)}.',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _AnalyticsTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}