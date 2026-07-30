class PaybillSettlement {
  final String id;
  final double amount;
  final String status;
  final DateTime settledAt;

  PaybillSettlement({required this.id, required this.amount, required this.status, required this.settledAt});

  factory PaybillSettlement.fromJson(Map<String, dynamic> json) {
    return PaybillSettlement(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'unknown',
      settledAt: DateTime.tryParse(json['settled_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
