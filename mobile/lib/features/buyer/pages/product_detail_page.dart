// lib/features/buyer/pages/product_detail_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../widgets/farmer_card.dart';

class ProductDetailPage extends StatefulWidget {
  final String? productId;
  final String? productUuid;
  final Product? initialProduct;
  const ProductDetailPage({super.key, this.productId, this.productUuid, this.initialProduct});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  bool _isFavourite = false;
  bool _addingToCart = false;

  @override
  void initState() {
    super.initState();
    final initialProduct = widget.initialProduct;
    if (initialProduct != null) {
      _isFavourite = ProductBloc.isFavorite(initialProduct);
    }
  }

  Product? get _product {
    final state = context.read<ProductBloc>().state;
    if (widget.initialProduct != null) {
      return widget.initialProduct;
    }
    if (state is ProductLoaded) {
      try {
        final targetId = widget.productId ?? widget.productUuid;
        return state.products.firstWhere((p) {
          final idText = p.id.toString();
          return idText == targetId || p.uuid == targetId;
        });
      } catch (_) {}
    }
    return null;
  }

  Future<void> _addToCart() async {
    final product = _product;
    if (product == null) return;
    setState(() => _addingToCart = true);
    try {
      await GetIt.I<CartRepository>().addProduct(product, _quantity.toDouble());
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Added to cart!');
        context.go(RoutePaths.cart);
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(RoutePaths.productCatalog),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          ),
        ),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final total = (product.pricePerUnit * _quantity).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Hero image app bar ────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.canPop()
                  ? context.pop()
                  : context.go(RoutePaths.productCatalog),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () =>
                      setState(() {
                      _isFavourite = !_isFavourite;
                      context
                        .read<ProductBloc>()
                        .add(ToggleFavoriteEvent(product));
                      }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _isFavourite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavourite
                          ? AppColors.error
                          : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.imageUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                  if (product.isOrganic)
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text('Organic',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.dark,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 14,
                                    color: AppColors.gold),
                                const SizedBox(width: 3),
                                Text(
                                  '${product.averageRating}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.dark,
                                      ),
                                ),
                                Text(
                                  '  (${product.reviewCount} reviews)',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'KES ${product.pricePerUnit.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                          ),
                          Text(
                            'per ${product.unit}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Farmer card
                  FarmerCard(
                    farmerName: product.farmerName,
                    farmLocation: product.location ?? 'Kiambu',
                    distanceKm: product.distanceKm ?? 2.1,
                    isVerified: true,
                    imageUrl: null,
                  ),
                  const SizedBox(height: 16),

                  // Quick info chips
                  Row(
                    children: [
                      _InfoChip(
                          label: 'Available',
                          value: '${product.availableQuantity.toStringAsFixed(0)} ${product.unit}'),
                      const SizedBox(width: 10),
                      _InfoChip(
                          label: 'Harvested',
                          value: product.harvestDateLabel ?? '2 days ago'),
                      const SizedBox(width: 10),
                      _InfoChip(
                          label: 'Min Order',
                          value: '1 ${product.unit}'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    product.description ??
                        'Fresh produce sourced directly from certified farmers. No middlemen — fair prices for buyers and farmers alike.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                          height: 1.65,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Quantity selector
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Quantity',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.dark,
                              ),
                        ),
                        const Spacer(),
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                            }
                          },
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$_quantity',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.dark,
                                ),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add_rounded,
                          filled: true,
                          onTap: () {
                            if (_quantity < (product.availableQuantity.toInt())) {
                              setState(() => _quantity++);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Sticky bottom bar ─────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(
                  color: AppColors.light, width: 1)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.muted)),
                Text(
                  'KES $total',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                label: 'Add to Cart 🛒',
                isLoading: _addingToCart,
                onPressed: _addToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _QuantityButton(
      {required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(icon,
              size: 16, color: filled ? Colors.white : AppColors.primary),
        ),
      );
}