// lib/features/buyer/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../config/route_paths.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/cart_item.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cartRepo = GetIt.I<CartRepository>();

  @override
  Widget build(BuildContext context) {
    final groups = _cartRepo.itemsGroupedByFarmer;
    final subtotal = _cartRepo.subtotal;
    const deliveryFee = 150.0;
    final platformFee = (subtotal * 0.05).roundToDouble();
    final total = subtotal + deliveryFee + platformFee;

    if (groups.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context, 0),
        body: const EmptyState(
          emoji: '🛒',
          title: 'Your cart is empty',
          subtitle: 'Add fresh produce from nearby farmers to get started.',
          actionLabel: 'Browse Products',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, _cartRepo.totalItems),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Items grouped by farmer
            ...groups.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Farmer header
                      Row(
                        children: [
                          const Icon(Icons.eco_rounded,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            entry.key, // farmer name
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: AppColors.light),
                      ...entry.value.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Slidable(
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) {
                                    _cartRepo.removeItem(item.productId);
                                    setState(() {});
                                  },
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_rounded,
                                  label: 'Remove',
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ],
                            ),
                            child: CartItemWidget(
                              item: item,
                              onQtyChanged: (qty) {
                                _cartRepo.updateQuantity(
                                    item.productId, qty);
                                setState(() {});
                              },
                              onRemove: () {
                                _cartRepo.removeItem(item.productId);
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Order summary
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow('Subtotal',
                      'KES ${subtotal.toStringAsFixed(0)}'),
                  const SizedBox(height: 6),
                  _SummaryRow('Delivery fee',
                      'KES ${deliveryFee.toStringAsFixed(0)}'),
                  const SizedBox(height: 6),
                  _SummaryRow('Platform fee',
                      'KES ${platformFee.toStringAsFixed(0)}'),
                  const Divider(
                      height: 20,
                      color: AppColors.light,
                      thickness: 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark,
                              )),
                      Text(
                        'KES ${total.toStringAsFixed(0)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Delivery address
            CustomCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Deliver to',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w700,
                                    color: AppColors.dark)),
                        Text('Westlands, Nairobi',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.muted)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Change',
                        style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Proceed button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        color: Colors.white,
        child: CustomButton(
          label: 'Proceed to Payment — KES ${total.toStringAsFixed(0)}',
          onPressed: () => context.go(RoutePaths.checkout),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, int count) => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.dark),
        ),
        title: Text('My Cart',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                )),
        actions: [
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text('$count items',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12)),
              ),
            ),
        ],
      );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.muted)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                      fontWeight: FontWeight.w600, color: AppColors.dark)),
        ],
      );
}