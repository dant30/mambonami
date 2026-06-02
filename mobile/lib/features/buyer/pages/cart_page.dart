import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../features/buyer/widgets/cart_item.dart';
import '../../../shared/layouts/custom_app_bar.dart';

import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/empty_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartRepository = GetIt.instance<CartRepository>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'My Cart', showNotificationAction: true, showBackButton: true),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartRepository.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const EmptyState(
              title: 'Your cart is empty',
              description: 'Browse products and add fresh items to get started.',
              buttonText: 'Shop now',
              onButtonPressed: null,
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CartItemWidget(
                        item: item,
                        onRemove: () => cartRepository.removeProduct(item.product.id),
                        onQuantityChanged: (quantity) => cartRepository.updateQuantity(item.product.id, quantity),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                CustomCard(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: theme.colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Order summary',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      _summaryRow(context, 'Items', cartRepository.itemCount.toString()),
                      const SizedBox(height: 10),
                      _summaryRow(context, 'Subtotal', 'Ksh ${cartRepository.subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 10),
                      _summaryRow(context, 'Weight', '${cartRepository.totalWeightKg.toStringAsFixed(2)} kg'),
                      const SizedBox(height: 20),
                      CustomButton(
                        label: 'Proceed to checkout',
                        onPressed: () => context.push(RoutePaths.checkout),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.75))),
        Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

