// mobile/lib/features/buyer/widgets/product_grid_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
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

    return GestureDetector(
      onTap: () => context.push(
        RoutePaths.productDetailPath(product.uuid),
        extra: product,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.large,
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image container
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 140,
                            color: AppColors.lightGreen.withOpacity(0.3),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 42,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      : Container(
                          height: 140,
                          color: AppColors.lightGreen.withOpacity(0.3),
                          child: const Icon(
                            Icons.shopping_basket,
                            size: 42,
                            color: AppColors.muted,
                          ),
                        ),
                ),
                // Badge
                if ((product.badge ?? '').isNotEmpty || (product.promoLabel ?? '').isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.small,
                      ),
                      child: Text(
                        product.badge ?? product.promoLabel!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white.withOpacity(0.9),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        context.read<ProductBloc>().add(
                              ToggleFavoriteEvent(product),
                            );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          product.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: product.isFavorite ? Colors.redAccent : AppColors.muted,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.all(12),
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
                  const SizedBox(height: 6),
                  Text(
                    'Ksh ${product.pricePerUnit.toStringAsFixed(2)} / ${product.unit}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.promoLabel != null && product.promoLabel!.isNotEmpty)
                    Text(
                      product.promoLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (product.averageRating > 0 || product.reviewCount > 0)
                    Row(
                      children: [
                        RatingStars(rating: product.averageRating, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${product.reviewCount}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: AppRadius.small,
                    ),
                    child: Text(
                      '${product.availableQuantity.toStringAsFixed(0)} ${product.unit}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}