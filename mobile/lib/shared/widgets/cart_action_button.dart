// mobile/lib/shared/widgets/cart_action_button.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../config/route_paths.dart';
import '../../data/repositories/cart_repository.dart';

class CartActionButton extends StatelessWidget {
  final bool showBadge;
  final Color? badgeColor;
  final IconData icon;

  const CartActionButton({
    super.key,
    this.showBadge = true,
    this.badgeColor,
    this.icon = Icons.shopping_cart_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartRepository = GetIt.instance<CartRepository>();

    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: cartRepository.items,
      builder: (context, items, child) {
        final itemCount = cartRepository.itemCount;
        final hasItems = itemCount > 0;

        if (!showBadge || !hasItems) {
          return IconButton(
            icon: Icon(icon),
            onPressed: () => context.push(RoutePaths.cart),
            tooltip: 'Shopping cart',
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(icon),
              onPressed: () => context.push(RoutePaths.cart),
              tooltip: 'Shopping cart',
            ),
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: badgeColor ?? theme.colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  itemCount > 99 ? '99+' : itemCount.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
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