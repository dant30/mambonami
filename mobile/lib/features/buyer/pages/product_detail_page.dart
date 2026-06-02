import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_indicator.dart';

class ProductDetailPage extends StatefulWidget {
  final String productUuid;
  final Product? initialProduct;

  const ProductDetailPage({super.key, required this.productUuid, this.initialProduct});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? _product;

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
      appBar: CustomAppBar(title: 'Product Detail', showNotificationAction: true, actions: const [CartActionButton()]),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (_product != null && state is! ProductLoading) {
            return _buildDetail(context, _product!);
          }

          if (state is ProductLoading) {
            return const LoadingIndicator();
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
                category: ProductCategory(id: 0, code: '', name: '', baseUnit: '', isActive: false),
                name: 'Unknown product',
                variety: null,
                pricePerUnit: 0,
                availableQuantity: 0,
                unit: '',
                harvestDate: DateTime.now(),
                shelfLifeDays: 0,
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

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
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
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      child: const Center(child: Icon(Icons.image_not_supported, size: 52)),
                    ),
                  )
                else
                  Container(
                    height: 260,
                    width: double.infinity,
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    child: const Center(child: Icon(Icons.shopping_basket, size: 60)),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.background.withOpacity(0.0), theme.colorScheme.background.withOpacity(0.95)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: available ? theme.colorScheme.primary : theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            available ? 'In stock' : 'Out of stock',
                            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Spacer(),
                        if (product.unit.isNotEmpty)
                          Text('${product.unit.toUpperCase()}', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.75))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(product.displayName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(product.category.name.toUpperCase(), style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 24),
          CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(context, 'Price', 'Ksh ${product.pricePerUnit.toStringAsFixed(2)} / ${product.unit}'),
                _buildInfoRow(context, 'Available', '${product.availableQuantity.toStringAsFixed(0)} ${product.unit}'),
                _buildInfoRow(context, 'Weight per unit', '${product.weightPerUnit.toStringAsFixed(2)} kg'),
                if (product.pickupLat != null && product.pickupLng != null)
                  _buildInfoRow(context, 'Pickup location', '${product.pickupLat!.toStringAsFixed(5)}, ${product.pickupLng!.toStringAsFixed(5)}'),
                _buildInfoRow(context, 'Farmer', product.farmerName.isNotEmpty ? product.farmerName : product.farmerPhone),
                _buildInfoRow(context, 'Harvested', product.harvestDate.toLocal().toString().split(' ').first),
                _buildInfoRow(context, 'Shelf life', '${product.remainingShelfLife} days remaining'),
              ],
            ),
          ),
          if (product.description != null && product.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            CustomCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(product.description!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          CustomButton(
            label: available ? 'Add to cart' : 'Unavailable',
            enabled: available,
            onPressed: available
                ? () {
                    final cartRepository = GetIt.instance<CartRepository>();
                    cartRepository.addProduct(product, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${product.displayName} to cart.'),
                        action: SnackBarAction(
                          label: 'View cart',
                          onPressed: () => context.go(RoutePaths.cart),
                        ),
                      ),
                    );
                  }
                : () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value, textAlign: TextAlign.right, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
