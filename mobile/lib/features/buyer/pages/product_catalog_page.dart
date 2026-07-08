// lib/features/buyer/pages/product_catalog_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/product_grid_tile.dart';
import '../widgets/product_search_bar.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  final _searchCtrl = TextEditingController();
  int _selectedCategory = 0;
  String _sortBy = 'Latest';

  final _categories = [
    'All', 'Vegetables', 'Fruits', 'Grains', 'Dairy', 'Roots', 'Livestock',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchProductsEvent());
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<ProductBloc>().add(
          SearchProductsEvent(query: _searchCtrl.text.trim()),
        );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SortBottomSheet(
        current: _sortBy,
        onSelected: (v) {
          setState(() => _sortBy = v);
          context.read<ProductBloc>().add(SortProductsEvent(sortBy: v));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search + filter
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.light,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProductSearchBar(
                          controller: _searchCtrl,
                          onFilter: _showSortSheet,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CategoryChipBar(
                    categories: _categories,
                    selected: _selectedCategory,
                    onSelected: (i) {
                      setState(() => _selectedCategory = i);
                      context.read<ProductBloc>().add(
                            FilterProductsByCategoryEvent(
                                category: _categories[i]),
                          );
                    },
                  ),
                ],
              ),
            ),

            // Results count + sort label
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  final count =
                      state is ProductLoaded ? state.products.length : 0;
                  return Row(
                    children: [
                      Text(
                        '$count products found',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _showSortSheet,
                        child: Row(
                          children: [
                            const Icon(Icons.sort_rounded,
                                size: 15, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              _sortBy,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Product grid
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  if (state is ProductError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 48),
                          const SizedBox(height: 12),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<ProductBloc>()
                                .add(FetchProductsEvent()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is ProductLoaded && state.products.isEmpty) {
                    return const EmptyState(
                      emoji: '🥦',
                      title: 'No products found',
                      subtitle:
                          'Try a different search term or category filter.',
                    );
                  }
                  if (state is ProductLoaded) {
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, i) =>
                          ProductGridTile(product: state.products[i]),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortBottomSheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelected;
  const _SortBottomSheet(
      {required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const options = [
      'Latest', 'Price: Low to High', 'Price: High to Low',
      'Nearest Farmer', 'Top Rated',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort by',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ...options.map((opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(opt),
                trailing: current == opt
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary)
                    : null,
                onTap: () {
                  onSelected(opt);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}