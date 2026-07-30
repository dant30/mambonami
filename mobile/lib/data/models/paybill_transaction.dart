class PaybillTransaction {
  final String id;
  final String phone;
  final String account;
  final double amount;
  final String status;
  final DateTime createdAt;

  PaybillTransaction({required this.id, required this.phone, required this.account, required this.amount, required this.status, required this.createdAt});

  factory PaybillTransaction.fromJson(Map<String, dynamic> json) {
    return PaybillTransaction(
      id: json['id']?.toString() ?? json['transaction_id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['msisdn']?.toString() ?? '',
      account: json['account']?.toString() ?? json['account_number']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'unknown',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
