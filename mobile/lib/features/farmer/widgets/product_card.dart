// lib/features/farmer/widgets/product_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../shared/themes/app_colors.dart';

class FarmerProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDeactivate;
  final VoidCallback? onShare;

  const FarmerProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.onDeactivate,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = product.isActive;
    final isOutOfStock = product.availableQuantity <= 0;
    final isLowStock = isActive && !isOutOfStock && product.availableQuantity < 20;
    final stockStatus = isOutOfStock ? 'Out of Stock' : (isLowStock ? 'Low Stock' : 'In Stock');
    final stockColor = isOutOfStock ? AppColors.error : (isLowStock ? AppColors.warning : AppColors.success);
    final progress = isOutOfStock
        ? 0.0
        : (product.availableQuantity / (product.availableQuantity + product.reservedQuantity)).clamp(0.0, 1.0);

    // Category accent color (simple mapping)
    Color categoryColor = AppColors.primary;
    final catName = product.category.name.toLowerCase();
    if (catName.contains('vegetable')) {
      categoryColor = const Color(0xFF2E7D32);
    } else if (catName.contains('fruit')) categoryColor = const Color(0xFFE65100);
    else if (catName.contains('grain')) categoryColor = const Color(0xFFBF8F00);
    else if (catName.contains('dairy')) categoryColor = const Color(0xFF1565C0);
    else if (catName.contains('livestock')) categoryColor = const Color(0xFF5D4037);

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────────
            Stack(
              children: [
                _buildImage(height: 160),
                // Gradient overlay at bottom for readability
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.25)],
                      ),
                    ),
                  ),
                ),
                // Status chip
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: stockColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      stockStatus,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                // Organic badge
                if (product.isOrganic)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'Organic',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            // ── Details ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.category.name,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                      const SizedBox(width: 2),
                      Text(
                        product.averageRating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.displayName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'KES ${product.pricePerUnit.toStringAsFixed(0)}/${product.unit}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                      const Spacer(),
                      if (!isOutOfStock)
                        Text(
                          '${product.availableQuantity.toStringAsFixed(0)} ${product.unit}',
                          style: const TextStyle(fontSize: 11, color: AppColors.muted),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Stock progress bar
                  if (!isOutOfStock) ...[
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.light,
                            valueColor: AlwaysStoppedAnimation<Color>(progress < 0.3 ? AppColors.warning : AppColors.secondary),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  // Reserved quantity if any
                  if (product.reservedQuantity > 0)
                    Text(
                      'Reserved: ${product.reservedQuantity.toStringAsFixed(0)} ${product.unit}',
                      style: const TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  const SizedBox(height: 6),
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Edit button
                      _ActionButton(
                        icon: Icons.edit_outlined,
                        color: AppColors.primary,
                        onPressed: onEdit ??
                            () => context.go(
                                  RoutePaths.farmerProductEditPath(product.uuid),
                                  extra: product,
                                ),
                      ),
                      // More menu
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18, color: AppColors.muted),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              (onEdit ??
                                      () => context.go(
                                            RoutePaths.farmerProductEditPath(product.uuid),
                                            extra: product,
                                          ))
                                  .call();
                              break;
                            case 'duplicate':
                              onDuplicate?.call();
                              break;
                            case 'deactivate':
                              onDeactivate?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                            case 'share':
                              onShare?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                          PopupMenuItem(
                            value: 'deactivate',
                            child: Text(product.isActive ? 'Deactivate' : 'Activate'),
                          ),
                          const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                          const PopupMenuItem(value: 'share', child: Text('Share')),
                        ],
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

  Widget _buildImage({double? height}) {
    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: product.imageUrl!,
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: height,
                color: AppColors.light,
                child: const Icon(Icons.image_outlined, color: AppColors.muted),
              ),
              errorWidget: (_, __, ___) => Container(
                height: height,
                color: AppColors.light,
                child: const Icon(Icons.broken_image_outlined, color: AppColors.muted),
              ),
            )
          : Container(
              height: height,
              color: AppColors.light,
              child: const Icon(Icons.grass, color: AppColors.muted),
            ),
    );
  }
}

// ── Reusable action button ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _ActionButton({required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
