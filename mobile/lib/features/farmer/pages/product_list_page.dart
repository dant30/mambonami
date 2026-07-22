// lib/features/farmer/pages/product_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../data/models/product.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/themes/app_gradients.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/section_header.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchProducts() {
    context.read<ProductBloc>().add(const FetchProductsEvent());
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Are you sure you want to delete "${product.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed == true) {
      context.read<ProductBloc>().add(DeleteProductEvent(product.uuid));
    }
  }

  List<Product> _filteredProducts(List<Product> products) {
    final query = _searchController.text.toLowerCase();
    return products.where((product) {
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Active' && product.isActive) ||
          (_selectedFilter == 'Inactive' && !product.isActive);
      final matchesSearch = query.isEmpty ||
          product.displayName.toLowerCase().contains(query) ||
          product.category.name.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _navigateToCreate() {
    context.go(RoutePaths.farmerProductCreate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Products',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go(RoutePaths.farmerDashboard);
            }
          },
        ),
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
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product "${state.product.displayName}" created.'),
                backgroundColor: AppColors.success,
              ),
            );
            _fetchProducts();
          }
          if (state is ProductUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product "${state.product.displayName}" updated.'),
                backgroundColor: AppColors.success,
              ),
            );
            _fetchProducts();
          }
          if (state is ProductDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product deleted.'),
                backgroundColor: AppColors.success,
              ),
            );
            _fetchProducts();
          }
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
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

          final visibleProducts = _filteredProducts(products);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Inventory summary card ──────────────────────────────────
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppGradients.hero,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory at a glance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Track your catalog, status, and freshness in one place.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SummaryChip(label: '${products.length} listings', color: Colors.white.withValues(alpha: 0.25)),
                        _SummaryChip(label: '${products.where((p) => p.isActive).length} active', color: AppColors.success),
                        _SummaryChip(label: '${products.where((p) => !p.isActive).length} paused', color: AppColors.warning),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Search bar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search products or categories',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Filter chips ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: ['All', 'Active', 'Inactive'].map((filter) {
                    final selected = _selectedFilter == filter;
                    return FilterChip(
                      label: Text(filter),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedFilter = filter),
                      selectedColor: AppColors.primary.withValues(alpha: 0.16),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? AppColors.primary : AppColors.muted,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // ── Section header with add button ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(
                  title: 'Your listings',
                  subtitle: 'Tap a card to edit or manage stock',
                  trailing: TextButton(
                    onPressed: _navigateToCreate,
                    child: const Text('Add'),
                  ),
                ),
              ),

              // ── Product grid ────────────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _fetchProducts(),
                  child: visibleProducts.isEmpty
                      ? ListView(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: EmptyState(
                                title: 'No matching products',
                                description: 'Try a different search or filter.',
                                icon: Icons.search_off,
                              ),
                            ),
                          ],
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.66,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: visibleProducts.length,
                          itemBuilder: (context, index) {
                            final product = visibleProducts[index];
                            return FarmerProductCard(
                              product: product,
                              onEdit: () => context.go(
                                RoutePaths.farmerProductEditPath(product.uuid),
                                extra: product,
                              ),
                              onDelete: () => _confirmDelete(product),
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

// ── Helper widget for summary chips ──────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SummaryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}