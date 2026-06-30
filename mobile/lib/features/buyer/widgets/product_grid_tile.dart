// mobile/lib/features/buyer/widgets/product_grid_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';

import '../../../data/models/product.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/rating_stars.dart';

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
            Stack(
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: theme.colorScheme.surface.withOpacity(0.85),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        context.read<ProductBloc>().add(ToggleFavoriteEvent(product));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          product.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: product.isFavorite ? Colors.redAccent : theme.colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                    const SizedBox(height: 8),
                    if (product.averageRating > 0 || product.reviewCount > 0)
                      Row(
                        children: [
                          RatingStars(rating: product.averageRating, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${product.reviewCount} review${product.reviewCount == 1 ? '' : 's'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
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
