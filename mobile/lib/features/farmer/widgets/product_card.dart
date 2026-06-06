import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../shared/themes/app_colors.dart';

class FarmerProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const FarmerProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ??
            () => context.go(RoutePaths.farmerProductEditPath(product.uuid),
                extra: product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image_not_supported, size: 42)),
                ),
              )
            else
              Container(
                height: 120,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                child: const Center(child: Icon(Icons.grass, size: 42)),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        'Ksh ${product.pricePerUnit.toStringAsFixed(2)} / ${product.unit}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.farmerAccent,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.isActive
                              ? theme.colorScheme.primary
                                  .withValues(alpha: 0.12)
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.isActive ? 'Active' : 'Inactive',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: product.isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        '${product.availableQuantity.toStringAsFixed(0)} avail',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 36, minHeight: 36),
                          icon: const Icon(Icons.edit, size: 16),
                          color: theme.colorScheme.primary,
                          onPressed: onEdit ??
                              () => context.go(
                                  RoutePaths.farmerProductEditPath(
                                      product.uuid),
                                  extra: product),
                        ),
                        if (onDelete != null)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            color: theme.colorScheme.error,
                            onPressed: onDelete,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
