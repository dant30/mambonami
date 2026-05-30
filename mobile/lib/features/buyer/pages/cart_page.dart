import 'package:flutter/material.dart';
import '../../../shared/themes/app_shadows.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_theme_extension.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/models/cart_item.dart';
import '../widgets/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartRepository = GetIt.instance<CartRepository>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'My Cart', showNotificationAction: true),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartRepository.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const EmptyState(message: 'Your cart is empty. Add products to continue.');
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
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
                _CheckoutSummary(cartRepository: cartRepository),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  final CartRepository cartRepository;

  const _CheckoutSummary({required this.cartRepository});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: Theme.of(context).extension<AppThemeExtension>()?.softShadow ?? AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Order Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items'),
              Text(cartRepository.itemCount.toString()),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('₦${cartRepository.subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated weight'),
              Text('${cartRepository.totalWeightKg.toStringAsFixed(2)} kg'),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push(RoutePaths.checkout),
            child: const Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }
}

