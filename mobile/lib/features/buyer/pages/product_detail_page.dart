// mobile/lib/features/buyer/pages/product_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_radius.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../../../shared/widgets/custom_snackbar.dart';

class ProductDetailPage extends StatefulWidget {
  final String productUuid;
  final Product? initialProduct;

  const ProductDetailPage({super.key, required this.productUuid, this.initialProduct});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? _product;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct;
    if (_product == null) {
      context.read<ProductBloc>().add(FetchProductDetailEvent(widget.productUuid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product Detail',
        showNotificationAction: true,
        actions: const [CartActionButton()],
        fallbackRoute: RoutePaths.products,
        backgroundColor: AppColors.background,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (_product != null && state is! ProductLoading) {
            return _buildDetail(context, _product!);
          }

          if (state is ProductLoading) {
            return const LoadingIndicator(message: 'Loading product...');
          }

          if (state is ProductDetailLoaded) {
            return _buildDetail(context, state.product);
          }

          if (state is ProductError) {
            return Center(child: Text(state.message));
          }

          if (state is ProductLoaded && _product == null) {
            final product = state.products.firstWhere(
              (item) => item.uuid == widget.productUuid,
              orElse: () => Product(
                id: 0,
                uuid: widget.productUuid,
                farmerId: 0,
                farmerPhone: '',
                farmerName: '',
                category: ProductCategory(id: 0, code: '', name: '', isActive: false),
                name: 'Unknown product',
                variety: null,
                sku: null,
                pricePerUnit: 0,
                availableQuantity: 0,
                reservedQuantity: 0,
                unit: '',
                harvestDate: DateTime.now(),
                shelfLifeDays: 0,
                expiryDate: null,
                isOrganic: false,
                remainingShelfLife: 0,
                isActive: false,
                imageUrl: null,
                description: null,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
            return _buildDetail(context, product);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final available = product.availableQuantity > 0;
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Hero Image ──────────────────────────────────────────────
          ClipRRect(
            borderRadius: AppRadius.extraLarge,
            child: Stack(
              children: [
                if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  Image.network(
                    product.imageUrl!,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 260,
                      color: AppColors.primary.withOpacity(0.08),
                      child: const Icon(Icons.image_not_supported, size: 52, color: AppColors.muted),
                    ),
                  )
                else
                  Container(
                    height: 260,
                    color: AppColors.primary.withOpacity(0.08),
                    child: const Icon(Icons.shopping_basket, size: 60, color: AppColors.muted),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.background.withOpacity(0.0),
                          AppColors.background.withOpacity(isDark ? 0.92 : 0.95),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: available ? AppColors.primary : AppColors.error,
                            borderRadius: AppRadius.medium,
                          ),
                          child: Text(
                            available ? 'In stock' : 'Out of stock',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (product.unit.isNotEmpty)
                          Text(
                            product.unit.toUpperCase(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Title & Rating ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      product.displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.category.name.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tags
                    if (product.badge != null ||
                        product.promoLabel != null ||
                        (product.minOrderQuantity != null && product.minOrderQuantity! > 0) ||
                        product.location != null ||
                        product.distanceKm != null)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (product.isOrganic)
                            _buildPill(context, Icons.eco_outlined, 'Organic'),
                          if (product.badge != null && product.badge!.isNotEmpty)
                            _buildPill(context, Icons.local_offer_outlined, product.badge!),
                          if (product.promoLabel != null && product.promoLabel!.isNotEmpty)
                            _buildPill(context, Icons.discount_outlined, product.promoLabel!),
                          if (product.minOrderQuantity != null && product.minOrderQuantity! > 0)
                            _buildPill(context, Icons.inventory_2_outlined, 'Min order ${product.minOrderQuantity!.toStringAsFixed(0)} ${product.unit}'),
                          if (product.location != null && product.location!.isNotEmpty)
                            _buildPill(context, Icons.location_on_outlined, product.location!),
                          if (product.distanceKm != null)
                            _buildPill(context, Icons.route_outlined, '${product.distanceKm!.toStringAsFixed(1)} km away'),
                        ],
                      ),
                    const SizedBox(height: 12),
                    if (product.averageRating > 0 || product.reviewCount > 0)
                      Row(
                        children: [
                          RatingStars(rating: product.averageRating, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            '${product.averageRating.toStringAsFixed(1)} · ${product.reviewCount} review${product.reviewCount == 1 ? '' : 's'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'No reviews yet',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () => context.read<ProductBloc>().add(ToggleFavoriteEvent(product)),
                    icon: Icon(
                      product.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: product.isFavorite ? Colors.redAccent : AppColors.muted,
                    ),
                    tooltip: product.isFavorite ? 'Remove from wishlist' : 'Save product',
                  ),
                  IconButton(
                    onPressed: () => Share.share(
                      'Check out ${product.displayName} on Mambonami: https://mambonami.com/product/${product.uuid}',
                    ),
                    icon: const Icon(Icons.share_outlined, color: AppColors.muted),
                    tooltip: 'Share product',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ─── Farmer Info ──────────────────────────────────────────────
          CustomCard(
            padding: const EdgeInsets.all(12),
            margin: EdgeInsets.zero,
            onTap: () {
              // Navigate to farmer profile (future)
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    product.farmerName.isNotEmpty ? product.farmerName[0].toUpperCase() : 'F',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.farmerName.isNotEmpty ? product.farmerName : product.farmerPhone,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      if (product.location != null)
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
                            const SizedBox(width: 4),
                            Text(
                              product.location!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: AppRadius.small,
                  ),
                  child: Text(
                    'Verified',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Details Grid ──────────────────────────────────────────────
          CustomCard(
            padding: const EdgeInsets.all(16),
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _buildInfoRow(context, 'Price', 'Ksh ${product.pricePerUnit.toStringAsFixed(2)} / ${product.unit}'),
                _buildInfoRow(context, 'Available', '${product.availableQuantity.toStringAsFixed(0)} ${product.unit}'),
                if (product.minOrderQuantity != null && product.minOrderQuantity! > 0)
                  _buildInfoRow(context, 'Minimum order', '${product.minOrderQuantity!.toStringAsFixed(0)} ${product.unit}'),
                _buildInfoRow(context, 'Harvested', product.harvestDate.toLocal().toString().split(' ').first),
                _buildInfoRow(context, 'Shelf life', '${product.remainingShelfLife} days remaining'),
                if (product.distanceKm != null)
                  _buildInfoRow(context, 'Distance', '${product.distanceKm!.toStringAsFixed(1)} km away'),
                if (product.pickupLat != null && product.pickupLng != null)
                  _buildInfoRow(context, 'Pickup location', '${product.pickupLat!.toStringAsFixed(5)}, ${product.pickupLng!.toStringAsFixed(5)}'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Description ──────────────────────────────────────────────
          if (product.description != null && product.description!.isNotEmpty)
            CustomCard(
              padding: const EdgeInsets.all(16),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // ─── Quantity Selector ────────────────────────────────────────
          CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: EdgeInsets.zero,
            child: Row(
              children: [
                Text(
                  'Quantity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1 ? () => setState(() => _quantity -= 1) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: _quantity > 1 ? AppColors.primary : AppColors.muted,
                    ),
                    Text(
                      '$_quantity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    IconButton(
                      onPressed: product.availableQuantity > _quantity
                          ? () => setState(() => _quantity += 1)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: product.availableQuantity > _quantity
                          ? AppColors.primary
                          : AppColors.muted,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Add to Cart Button ──────────────────────────────────────
          CustomButton(
            label: available ? 'Add $_quantity to cart' : 'Unavailable',
            enabled: available,
            onPressed: available
                ? () {
                    final cartRepository = GetIt.instance<CartRepository>();
                    cartRepository.addProduct(product, _quantity.toDouble());
                    CustomSnackbar.showSuccess(
                      context,
                      'Added $_quantity x ${product.displayName} to cart.',
                    );
                  }
                : null,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPill(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}