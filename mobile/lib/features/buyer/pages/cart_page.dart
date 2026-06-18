// mobile/lib/features/buyer/pages/cart_page.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartRepository = GetIt.instance<CartRepository>();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Cart',
        showNotificationAction: true,
        showBackButton: true,
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cartRepository.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const EmptyState(
              title: 'Your cart is empty',
              description: 'Browse fresh produce and add items to get started.',
              icon: Icons.shopping_basket_outlined,
              buttonText: 'Start Shopping',
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
                      return Slidable(
                        key: ValueKey(item.product.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => cartRepository.removeProduct(item.product.id),
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: Colors.white,
                              icon: Icons.delete_outline,
                              label: 'Remove',
                            ),
                          ],
                        ),
                        child: CartItemWidget(
                          item: item,
                          onRemove: () => cartRepository.removeProduct(item.product.id),
                          onQuantityChanged: (quantity) =>
                              cartRepository.updateQuantity(item.product.id, quantity),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildOrderSummary(context, cartRepository),
                const SizedBox(height: 8),
                _buildPromoSection(context),
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Proceed to Checkout',
                  onPressed: () => context.push(RoutePaths.checkout),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartRepository repository) {
    final theme = Theme.of(context);
    final items = repository.items.value;
    final totalItems = items.fold(0, (sum, item) => sum + item.quantity.toInt());
    final subtotal = repository.subtotal;
    final deliveryEstimate = subtotal > 200 ? 0.0 : 100.0;
    final total = subtotal + deliveryEstimate;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Order Summary',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _summaryRow(context, 'Items (${totalItems})', '${totalItems}'),
          const SizedBox(height: 10),
          _summaryRow(context, 'Subtotal', 'Ksh ${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _summaryRow(
            context,
            'Delivery Estimate',
            deliveryEstimate == 0 ? 'Free' : 'Ksh ${deliveryEstimate.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 10),
          _summaryRow(
            context,
            'Total',
            'Ksh ${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter promo code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isTotal ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.75),
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}