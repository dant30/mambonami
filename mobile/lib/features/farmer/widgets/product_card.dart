// lib/features/farmer/widgets/product_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';

/// A card widget that displays a farmer's product in either list or grid style.
/// 
/// [isGrid] - when true, displays in a vertical layout (suitable for GridView);
/// otherwise displays in a horizontal layout (suitable for ListView).
class FarmerProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool isGrid;

  const FarmerProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = product.isActive;
    final isLowStock = isActive && product.availableQuantity < 20;
    final statusColor = isActive
        ? (isLowStock ? AppColors.warning : AppColors.success)
        : AppColors.muted;
    final statusLabel = isActive
        ? (isLowStock ? 'Low Stock' : 'Active')
        : 'Inactive';

    // ── Content ──────────────────────────────────────────────────────────
    Widget content = isGrid
        ? _buildGridContent(context, statusColor, statusLabel)
        : _buildListContent(context, statusColor, statusLabel);

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
        child: InkWell(
          onTap: onTap ??
              () => context.go(
                    RoutePaths.farmerProductEditPath(product.uuid),
                    extra: product,
                  ),
          child: content,
        ),
      ),
    );
  }

  // ── Grid Layout (vertical) ────────────────────────────────────────────
  Widget _buildGridContent(
    BuildContext context,
    Color statusColor,
    String statusLabel,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        _buildImage(height: 140),
        // Details
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildStatusBadge(statusColor, statusLabel),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${product.category.name} · ${product.availableQuantity.toStringAsFixed(0)} ${product.unit}',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'KES ${product.pricePerUnit.toStringAsFixed(0)}/${product.unit}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                  const SizedBox(width: 2),
                  Text(
                    '${product.averageRating.toStringAsFixed(1)}',
                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildActionButtons(context),
            ],
          ),
        ),
      ],
    );
  }

  // ── List Layout (horizontal) ──────────────────────────────────────────
  Widget _buildListContent(
    BuildContext context,
    Color statusColor,
    String statusLabel,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Image
          _buildImage(width: 72, height: 72),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.category.name} · ${product.availableQuantity.toStringAsFixed(0)} ${product.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'KES ${product.pricePerUnit.toStringAsFixed(0)}/${product.unit}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // Right side: status badge + actions
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusBadge(statusColor, statusLabel),
              const SizedBox(height: 8),
              _buildActionButtons(context),
            ],
          ),
        ],
      ),
    );
  }

  // ── Image widget ──────────────────────────────────────────────────────
  Widget _buildImage({double? width, double? height}) {
    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: product.imageUrl!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: width,
                height: height,
                color: AppColors.light,
                child: const Icon(Icons.image_outlined, color: AppColors.muted),
              ),
              errorWidget: (context, url, error) => Container(
                width: width,
                height: height,
                color: AppColors.light,
                child: const Icon(Icons.broken_image_outlined,
                    color: AppColors.muted),
              ),
            )
          : Container(
              width: width,
              height: height,
              color: AppColors.light,
              child: const Icon(Icons.grass, color: AppColors.muted),
            ),
    );
  }

  // ── Status badge ──────────────────────────────────────────────────────
  Widget _buildStatusBadge(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.edit_outlined,
          color: AppColors.primary,
          onPressed: onEdit ??
              () => context.go(
                    RoutePaths.farmerProductEditPath(product.uuid),
                    extra: product,
                  ),
        ),
        const SizedBox(width: 6),
        if (onDelete != null)
          _ActionButton(
            icon: Icons.delete_outline_rounded,
            color: AppColors.error,
            onPressed: () => onDelete?.call(),
          ),
      ],
    );
  }
}

// ── Reusable action button ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

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