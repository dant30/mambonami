import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../local/database_helper.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../../core/constants.dart';

class CartRepository {
  final DatabaseHelper _databaseHelper = GetIt.instance<DatabaseHelper>();
  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  Future<void> init() async {
    await _restoreCart();
  }

  Future<void> _restoreCart() async {
    final records = await _databaseHelper.getRecords(kCartItemTable);
    final restored = <CartItem>[];
    for (final record in records) {
      try {
        restored.add(CartItem.fromJson(record));
      } catch (_) {
        // Skip invalid cached cart items.
      }
    }
    if (restored.isNotEmpty) {
      items.value = restored;
    }
  }

  Future<void> _saveCartItem(CartItem item) async {
    await _databaseHelper.insertOrUpdateRecord(
      kCartItemTable,
      item.product.id.toString(),
      item.toJson(),
    );
  }

  Future<void> _removeCartItem(int productId) async {
    await _databaseHelper.deleteRecord(kCartItemTable, productId.toString());
  }

  Future<void> _clearCartStorage() async {
    await _databaseHelper.clearTable(kCartItemTable);
  }

  int get itemCount =>
      items.value.fold(0, (count, item) => count + item.quantity.toInt());
  double get totalQuantity =>
      items.value.fold(0.0, (sum, item) => sum + item.quantity);
  double _backendSubtotal = 0.0;
  double _backendDeliveryFee = 0.0;
  double _backendServiceFee = 0.0;
  double _backendTotal = 0.0;

  bool get hasBackendFeeBreakdown =>
      _backendTotal > 0 || _backendDeliveryFee > 0 || _backendServiceFee > 0;

  double get subtotal => hasBackendFeeBreakdown
      ? _backendSubtotal
      : items.value.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get deliveryFee => hasBackendFeeBreakdown
      ? _backendDeliveryFee
      : (subtotal > 0 ? (subtotal * 0.08).clamp(120.0, 400.0) : 0.0);
  double get serviceFee => hasBackendFeeBreakdown
      ? _backendServiceFee
      : (subtotal > 0 ? (subtotal * 0.03).clamp(0.0, 600.0) : 0.0);
  double get total => hasBackendFeeBreakdown
      ? _backendTotal
      : subtotal + deliveryFee + serviceFee;
  double get totalWeightKg => items.value.fold(
      0.0, (sum, item) => sum + (item.product.weightPerUnit * item.quantity));

  void setBackendFeeBreakdown(
      {required double subtotal,
      required double deliveryFee,
      required double serviceFee,
      required double total}) {
    _backendSubtotal = subtotal;
    _backendDeliveryFee = deliveryFee;
    _backendServiceFee = serviceFee;
    _backendTotal = total;
  }

  Future<void> addProduct(Product product, double quantity) async {
    if (quantity <= 0) return;
    final existing =
        items.value.indexWhere((item) => item.product.id == product.id);
    if (existing >= 0) {
      final updated = items.value[existing]
          .copyWith(quantity: items.value[existing].quantity + quantity);
      final updatedItems = List<CartItem>.from(items.value);
      updatedItems[existing] = updated;
      items.value = updatedItems;
      await _saveCartItem(updated);
      return;
    }

    final newItem = CartItem(product: product, quantity: quantity);
    items.value = List<CartItem>.from(items.value)..add(newItem);
    await _saveCartItem(newItem);
  }

  Future<void> updateQuantity(int productId, double quantity) async {
    if (quantity <= 0) {
      await removeProduct(productId);
      return;
    }
    final existing =
        items.value.indexWhere((item) => item.product.id == productId);
    if (existing < 0) return;
    final updatedItems = List<CartItem>.from(items.value);
    final updated = updatedItems[existing].copyWith(quantity: quantity);
    updatedItems[existing] = updated;
    items.value = updatedItems;
    await _saveCartItem(updated);
  }

  Future<void> removeProduct(int productId) async {
    items.value =
        items.value.where((item) => item.product.id != productId).toList();
    await _removeCartItem(productId);
  }

  List<CartItem> get allItems => items.value;
  int get totalItems => itemCount;
  Map<String, List<CartItem>> get itemsGroupedByFarmer {
    final groups = <String, List<CartItem>>{};
    for (final item in items.value) {
      final key = item.product.farmerName.isNotEmpty
          ? item.product.farmerName
          : 'Unknown farmer';
      groups.putIfAbsent(key, () => <CartItem>[]).add(item);
    }
    return groups;
  }

  Future<void> addItem(
      {required int productId,
      required double quantity,
      required int farmerId}) async {
    final existing =
        items.value.indexWhere((item) => item.product.id == productId);
    if (existing >= 0) {
      await updateQuantity(
          productId, items.value[existing].quantity + quantity);
      return;
    }
    await Future<void>.value();
  }

  Future<void> removeItem(int productId) async => removeProduct(productId);

  Future<void> clear() async {
    items.value = [];
    _backendSubtotal = 0.0;
    _backendDeliveryFee = 0.0;
    _backendServiceFee = 0.0;
    _backendTotal = 0.0;
    await _clearCartStorage();
  }
}
