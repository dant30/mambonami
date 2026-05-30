import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';

import '../../../data/models/product.dart';

class ProductGridTile extends StatelessWidget {
  final Product product;

  const ProductGridTile({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => context.go(RoutePaths.productDetailPath(product.uuid), extra: product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 3,
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported, size: 48)),
                      ),
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      child: const Center(child: Icon(Icons.shopping_basket, size: 42)),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product.pricePerUnit.toStringAsFixed(2)} per ${product.unit}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Weight: ${product.weightPerUnit.toStringAsFixed(2)} kg/unit',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product.availableQuantity.toStringAsFixed(2)} ${product.unit} available',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
