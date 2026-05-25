class PaymentHelper {
  PaymentHelper._();

  /// Build a deep link URI for M-Pesa PayBill payments.
  ///
  /// This helper returns a URI that can be consumed by launcher packages
  /// when the app wants to hand the payment details to the M-Pesa app.
  static Uri buildMpesaPaybillUri({
    required String paybillNumber,
    required String accountReference,
    required String amount,
    String description = 'Payment',
  }) {
    return Uri(
      scheme: 'mpesa',
      host: 'paybill',
      queryParameters: {
        'paybill': paybillNumber,
        'account': accountReference,
        'amount': amount,
        'description': description,
      },
    );
  }

  /// Create a stable account reference for PayBill orders or deposits.
  static String buildAccountReference({
    required String prefix,
    required String identifier,
  }) {
    return '$prefix-$identifier';
  }

  /// Format a payment amount for display or deep-link payloads.
  static String formatAmount(num amount) {
    return amount.toStringAsFixed(0);
  }
}

