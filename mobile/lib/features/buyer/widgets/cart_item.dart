// lib/features/buyer/widgets/cart_item.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/models/cart_item.dart';
import '../../../shared/themes/app_colors.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final ValueChanged<double> onQtyChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQtyChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final lineTotal =
        (item.pricePerUnit * item.quantity).toStringAsFixed(0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: item.imageUrl ?? '',
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(color: AppColors.light),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.light,
              child: const Icon(Icons.image_not_supported_outlined,
                  color: AppColors.muted),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Name + price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'KES ${item.pricePerUnit.toStringAsFixed(0)} / ${item.unit}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 6),
              // Quantity stepper
              Row(
                children: [
                  _QtyButton(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      if (item.quantity > 1) {
                        onQtyChanged(item.quantity - 1);
                      } else {
                        onRemove();
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${item.quantity}',
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark,
                              ),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add_rounded,
                    filled: true,
                    onTap: () {
                      if (item.quantity < item.maxQty) {
                        onQtyChanged(item.quantity + 1);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Line total + delete
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'KES $lineTotal',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _QtyButton(
      {required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: filled
                ? null
                : Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Icon(icon,
              size: 14,
              color: filled ? Colors.white : AppColors.primary),
        ),
      );
}