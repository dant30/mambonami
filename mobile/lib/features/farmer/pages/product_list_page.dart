import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    context.read<ProductBloc>().add(const FetchProductsEvent());
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete product'),
          content: Text('Are you sure you want to delete "${product.displayName}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
          ],
        );
      },
    );

    if (confirmed == true) {
      context.read<ProductBloc>().add(DeleteProductEvent(product.uuid));
    }
  }

  void _navigateToCreate() {
    context.go(RoutePaths.farmerProductCreate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Products',
        showNotificationAction: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreate,
            tooltip: 'Add product',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product "${state.product.displayName}" created successfully.')),
            );
            _fetchProducts();
          }
          if (state is ProductUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product "${state.product.displayName}" updated successfully.')),
            );
            _fetchProducts();
          }
          if (state is ProductDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product deleted successfully.')),
            );
            _fetchProducts();
          }
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductLoading || state is ProductInitial) {
            return const LoadingIndicator();
          }

          final products = state is ProductLoaded ? state.products : <Product>[];
          if (products.isEmpty) {
            return EmptyState(
              title: 'No products yet',
              description: 'Add your first product so buyers can discover your farm listings.',
              buttonText: 'Create product',
              onButtonPressed: _navigateToCreate,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.78)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Products', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('Manage your catalog and listings', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _fetchProducts();
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bottomInset = MediaQuery.of(context).padding.bottom + 56.0; // account for system inset and possible bottom nav
                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return FarmerProductCard(
                            product: product,
                            onEdit: () => context.go(RoutePaths.farmerProductEditPath(product.uuid), extra: product),
                            onDelete: () => _confirmDelete(product),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
