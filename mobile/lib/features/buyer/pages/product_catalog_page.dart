// mobile/lib/features/buyer/pages/product_catalog_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../data/models/product.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/cart_action_button.dart';
import '../../../shared/widgets/product_list_tile.dart';
import '../../../shared/widgets/shimmer_grid.dart';
import '../widgets/product_grid_tile.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortOption = 'Latest';
  bool _isGridView = true;

  final List<String> _sortOptions = ['Latest', 'Price: Low-High', 'Price: High-Low', 'Popular'];

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const FetchProductsEvent());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterAndSortProducts(List<Product> products) {
    var filtered = products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.farmerName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || product.category.code == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    switch (_sortOption) {
      case 'Price: Low-High':
        filtered.sort((a, b) => a.pricePerUnit.compareTo(b.pricePerUnit));
        break;
      case 'Price: High-Low':
        filtered.sort((a, b) => b.pricePerUnit.compareTo(a.pricePerUnit));
        break;
      case 'Popular':
        filtered.sort((a, b) => b.availableQuantity.compareTo(a.availableQuantity));
        break;
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Market',
        showNotificationAction: true,
        actions: const [CartActionButton()],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.16)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Fresh picks, right now',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('Free delivery', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search produce, farms or categories',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                final categories = state is ProductLoaded
                    ? ['All', ...state.products.map((product) => product.category.code).where((code) => code.isNotEmpty).toSet().toList()]
                    : <String>['All'];
                return SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == _selectedCategory;
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = category);
                        },
                        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.16),
                        checkmarkColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.24)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: _sortOption,
                    items: _sortOptions.map((option) {
                      return DropdownMenuItem(value: option, child: Text(option, style: const TextStyle(fontSize: 14)));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _sortOption = value);
                    },
                    underline: const SizedBox(),
                    icon: const Icon(Icons.tune, size: 18),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_isGridView ? Icons.grid_view_rounded : Icons.list_rounded, size: 22),
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                  tooltip: _isGridView ? 'Switch to list' : 'Switch to grid',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => context.read<ProductBloc>().add(const FetchProductsEvent()),
                  tooltip: 'Refresh products',
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return _isGridView ? const ShimmerGrid(crossAxisCount: 2) : const ShimmerList();
                } else if (state is ProductLoaded) {
                  final products = _filterAndSortProducts(state.products);
                  if (products.isEmpty) {
                    return EmptyState(
                      title: 'No products found',
                      description: _searchQuery.isNotEmpty ? 'Try adjusting your search or filters' : 'No products available right now',
                      icon: Icons.search_off_outlined,
                      buttonText: 'Clear filters',
                      onButtonPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _selectedCategory = 'All';
                        });
                      },
                    );
                  }
                  return _isGridView ? _buildGridView(products) : _buildListView(products);
                } else if (state is ProductError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 12),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<ProductBloc>().add(const FetchProductsEvent()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Product> products) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductGridTile(product: product);
      },
    );
  }

  Widget _buildListView(List<Product> products) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductListTile(product: product),
        );
      },
    );
  }
}