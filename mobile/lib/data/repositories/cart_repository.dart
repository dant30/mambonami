import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartRepository {
  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  int get itemCount => items.value.fold(0, (count, item) => count + item.quantity.toInt());
  double get totalQuantity => items.value.fold(0.0, (sum, item) => sum + item.quantity);
  double get subtotal => items.value.fold(0.0, (sum, item) => sum + item.lineTotal);

  void addProduct(Product product, double quantity) {
    if (quantity <= 0) return;
    final existing = items.value.indexWhere((item) => item.product.id == product.id);
    if (existing >= 0) {
      final updated = items.value[existing].copyWith(quantity: items.value[existing].quantity + quantity);
      final updatedItems = List<CartItem>.from(items.value);
      updatedItems[existing] = updated;
      items.value = updatedItems;
      return;
    }

    items.value = List<CartItem>.from(items.value)..add(CartItem(product: product, quantity: quantity));
  }

  void updateQuantity(int productId, double quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    final existing = items.value.indexWhere((item) => item.product.id == productId);
    if (existing < 0) return;
    final updatedItems = List<CartItem>.from(items.value);
    updatedItems[existing] = updatedItems[existing].copyWith(quantity: quantity);
    items.value = updatedItems;
  }

  void removeProduct(int productId) {
    items.value = items.value.where((item) => item.product.id != productId).toList();
  }

  void clear() {
    items.value = [];
  }
}
