class PayoutSummary {
  final double totalPayoutAmount;
  final double completedPayoutAmount;
  final double pendingPayoutAmount;
  final double todayPayoutAmount;
  final int completedPayoutCount;
  final int pendingPayoutCount;
  final DateTime? latestPaidAt;

  const PayoutSummary({
    required this.totalPayoutAmount,
    required this.completedPayoutAmount,
    required this.pendingPayoutAmount,
    required this.todayPayoutAmount,
    required this.completedPayoutCount,
    required this.pendingPayoutCount,
    this.latestPaidAt,
  });

  factory PayoutSummary.fromJson(Map<String, dynamic> json) {
    return PayoutSummary(
      totalPayoutAmount: (json['total_payout_amount'] as num?)?.toDouble() ?? 0.0,
      completedPayoutAmount: (json['completed_payout_amount'] as num?)?.toDouble() ?? 0.0,
      pendingPayoutAmount: (json['pending_payout_amount'] as num?)?.toDouble() ?? 0.0,
      todayPayoutAmount: (json['today_payout_amount'] as num?)?.toDouble() ?? 0.0,
      completedPayoutCount: (json['completed_payout_count'] as num?)?.toInt() ?? 0,
      pendingPayoutCount: (json['pending_payout_count'] as num?)?.toInt() ?? 0,
      latestPaidAt: json['latest_paid_at'] != null
          ? DateTime.tryParse(json['latest_paid_at'].toString())
          : null,
    );
  }
}
