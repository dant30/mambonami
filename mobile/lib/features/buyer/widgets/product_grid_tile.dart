// lib/features/buyer/widgets/product_grid_tile.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../shared/themes/app_colors.dart';

class ProductGridTile extends StatefulWidget {
  final Product product;
  const ProductGridTile({super.key, required this.product});

  @override
  State<ProductGridTile> createState() => _ProductGridTileState();
}

class _ProductGridTileState extends State<ProductGridTile> {
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();
    _isFavourite = ProductBloc.isFavorite(widget.product);
  }

  @override
  void didUpdateWidget(covariant ProductGridTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.uuid != widget.product.uuid) {
      _isFavourite = ProductBloc.isFavorite(widget.product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return GestureDetector(
      onTap: () => context.go(RoutePaths.productDetailPath(p.uuid)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: p.imageUrl ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          color: AppColors.light,
                          child: const Icon(Icons.image_outlined,
                              color: AppColors.muted)),
                      errorWidget: (_, __, ___) => Container(
                          color: AppColors.light,
                          child: const Icon(Icons.broken_image_outlined,
                              color: AppColors.muted)),
                    ),
                  ),
                  // Badge
                  if (p.badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          p.badge!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  // Heart
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isFavourite = !_isFavourite);
                        context
                            .read<ProductBloc>()
                            .add(ToggleFavoriteEvent(p));
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6),
                          ],
                        ),
                        child: Icon(
                          _isFavourite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 15,
                          color: _isFavourite
                              ? AppColors.error
                              : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.farmerName ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KES ${p.pricePerUnit.toStringAsFixed(0)}/${p.unit}',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await GetIt.I<CartRepository>().addProduct(p, 1);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text('Added to cart'),
                                backgroundColor: AppColors.primary,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 11, color: AppColors.gold),
                      const SizedBox(width: 2),
                      Text(
                        '${p.averageRating}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                      ),
                    ],
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