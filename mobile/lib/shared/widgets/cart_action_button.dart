import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../config/route_paths.dart';
import '../../data/repositories/cart_repository.dart';

class CartActionButton extends StatelessWidget {
  final bool showBadge;

  const CartActionButton({super.key, this.showBadge = true});

  @override
  Widget build(BuildContext context) {
    final cartRepository = GetIt.instance<CartRepository>();

    return ValueListenableBuilder<List>(
      valueListenable: cartRepository.items,
      builder: (context, items, _) {
        final itemCount = cartRepository.itemCount;
        final hasItems = itemCount > 0;

        if (!showBadge || !hasItems) {
          return IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push(RoutePaths.cart),
            tooltip: 'Shopping cart',
          );
        }

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => context.push(RoutePaths.cart),
              tooltip: 'Shopping cart',
            ),
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  itemCount.toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onError,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
