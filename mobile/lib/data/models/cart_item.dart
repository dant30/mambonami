import 'package:equatable/equatable.dart';

import 'product.dart';

class CartItem extends Equatable {
  final Product product;
  final double quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({double? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  double get lineTotal => product.pricePerUnit * quantity;

  @override
  List<Object?> get props => [product.id, quantity];
}
