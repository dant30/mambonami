import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/custom_app_bar.dart';
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
      appBar: const CustomAppBar(title: 'Product Detail', showNotificationAction: true),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                product.imageUrl!,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 240,
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  child: const Center(child: Icon(Icons.image_not_supported, size: 52)),
                ),
              ),
            )
          else
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(child: Icon(Icons.shopping_basket, size: 60)),
            ),
          const SizedBox(height: 20),
          Text(product.displayName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(product.category.name.toUpperCase(), style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 20),
          _buildInfoRow(context, 'Price', '${product.pricePerUnit.toStringAsFixed(2)} per ${product.unit}'),
          _buildInfoRow(context, 'Available', '${product.availableQuantity.toStringAsFixed(2)} ${product.unit}'),
          _buildInfoRow(context, 'Weight per unit', '${product.weightPerUnit.toStringAsFixed(2)} kg'),
          if (product.pickupLat != null && product.pickupLng != null)
            _buildInfoRow(context, 'Pickup location', '${product.pickupLat!.toStringAsFixed(5)}, ${product.pickupLng!.toStringAsFixed(5)}'),
          _buildInfoRow(context, 'Farmer', product.farmerName.isNotEmpty ? product.farmerName : product.farmerPhone),
          _buildInfoRow(context, 'Harvested', product.harvestDate.toLocal().toString().split(' ').first),
          _buildInfoRow(context, 'Shelf life', '${product.remainingShelfLife} days remaining'),
          const SizedBox(height: 16),
          if (product.description != null && product.description!.isNotEmpty) ...[
            Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(product.description!),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: () {
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
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add to cart'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

