import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';

import '../../../data/models/product.dart';
import '../../../shared/themes/app_colors.dart';

class ProductGridTile extends StatelessWidget {
  final Product product;

  const ProductGridTile({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RoutePaths.productDetailPath(product.uuid),
            extra: product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_not_supported, size: 42)),
                    ),
                  )
                : Container(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    height: 120,
                    child: const Center(
                        child: Icon(Icons.shopping_basket, size: 42)),
                  ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ksh ${product.pricePerUnit.toStringAsFixed(2)} / ${product.unit}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.farmerAccent,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.availableQuantity.toStringAsFixed(1)} ${product.unit} available',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
