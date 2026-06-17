import 'package:equatable/equatable.dart';

import 'product.dart';

class CartItem extends Equatable {
  final Product product;
  final double quantity;

  const CartItem({required this.product, required this.quantity});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final rawProduct = json['product'];
    final productJson = rawProduct is Map<String, dynamic>
      ? rawProduct
      : rawProduct is Map
        ? Map<String, dynamic>.from(rawProduct)
        : null;
    final quantityValue = json['quantity'];

    if (productJson == null) {
      throw ArgumentError('Invalid cart item: missing product data');
    }

    final quantity = quantityValue is num
        ? quantityValue.toDouble()
        : double.tryParse(quantityValue?.toString() ?? '') ?? 0.0;

    return CartItem(
      product: Product.fromJson(productJson),
      quantity: quantity,
    );
  }

  CartItem copyWith({double? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  double get lineTotal => product.pricePerUnit * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  @override
  List<Object?> get props => [product.id, quantity];
}
