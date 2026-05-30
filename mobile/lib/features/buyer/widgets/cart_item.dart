import 'package:flutter/material.dart';

import '../../../data/models/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<double> onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.product.imageUrl!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    child: const Icon(Icons.image_not_supported, size: 32),
                  ),
                ),
              )
            else
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_basket, size: 32),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.displayName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text('Ksh ${item.product.pricePerUnit.toStringAsFixed(2)} / ${item.product.unit}', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onTap: () => onQuantityChanged((item.quantity - 1).clamp(1, item.product.availableQuantity)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(item.quantity.toStringAsFixed(0), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onTap: () => onQuantityChanged((item.quantity + 1).clamp(1, item.product.availableQuantity)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
                const SizedBox(height: 8),
                Text('Ksh ${item.lineTotal.toStringAsFixed(2)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, shape: const CircleBorder()),
        onPressed: onTap,
        child: Icon(icon, size: 18),
      ),
    );
  }
}
