// mobile/lib/features/buyer/widgets/cart_item.dart
import 'package:flutter/material.dart';
import '../../../data/models/cart_item.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';

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
    final product = item.product;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: AppRadius.medium,
              color: AppColors.lightGreen.withOpacity(0.3),
            ),
            child: ClipRRect(
              borderRadius: AppRadius.medium,
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported,
                        size: 32,
                        color: AppColors.muted,
                      ),
                    )
                  : const Icon(
                      Icons.shopping_basket,
                      size: 32,
                      color: AppColors.muted,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Ksh ${product.pricePerUnit.toStringAsFixed(2)} / ${product.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                // Quantity controls
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: () => onQuantityChanged(
                        (item.quantity - 1).clamp(1, product.availableQuantity),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.quantity.toStringAsFixed(0),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: () => onQuantityChanged(
                        (item.quantity + 1).clamp(1, product.availableQuantity),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Line total & remove button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.muted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                tooltip: 'Remove item',
              ),
              const SizedBox(height: 8),
              Text(
                'Ksh ${item.lineTotal.toStringAsFixed(2)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
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
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          backgroundColor: Colors.transparent,
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}