// lib/features/farmer/pages/product_list_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

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
  String _sortBy = 'Newest';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  final List<String> _filterOptions = [
    'All',
    'Active',
    'Inactive',
    'Low Stock',
    'Out of Stock',
  ];

  final List<String> _sortOptions = [
    'Newest',
    'Oldest',
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rated',
  ];

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
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      context.read<ProductBloc>().add(DeleteProductEvent(product.uuid));
    }
  }

  List<Product> _filteredAndSortedProducts(List<Product> products) {
    final query = _searchController.text.toLowerCase();
    var result = products.where((product) {
      final matchesFilter = switch (_selectedFilter) {
        'All' => true,
        'Active' => product.isActive,
        'Inactive' => !product.isActive,
        'Low Stock' => product.isActive && product.availableQuantity > 0 && product.availableQuantity < 20,
        'Out of Stock' => product.availableQuantity <= 0,
        _ => true,
      };
      final matchesSearch = query.isEmpty ||
          product.displayName.toLowerCase().contains(query) ||
          product.category.name.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'Newest':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Price: Low to High':
        result.sort((a, b) => a.pricePerUnit.compareTo(b.pricePerUnit));
        break;
      case 'Price: High to Low':
        result.sort((a, b) => b.pricePerUnit.compareTo(a.pricePerUnit));
        break;
      case 'Highest Rated':
        result.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
    }
    return result;
  }

  void _navigateToCreate() {
    context.go(RoutePaths.farmerProductCreate);
  }

  Future<void> _duplicateProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate product'),
        content: Text('Create a copy of "${product.displayName}" and keep the current stock and image details?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Duplicate')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Offload image download to a background task (using compute, but we'll do it in a simple way)
    File? imageFile;
    final imageUrl = product.imageUrl?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      try {
        // In a real app, move this to a repository with proper error handling.
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          final extension = imageUrl.split('?').first.split('.').last.toLowerCase();
          final fileName = '${product.uuid}_${DateTime.now().millisecondsSinceEpoch}.${extension.isNotEmpty && extension.length <= 5 ? extension : 'jpg'}';
          imageFile = File('${Directory.systemTemp.path}/$fileName');
          await imageFile.writeAsBytes(response.bodyBytes);
        }
      } catch (_) {
        imageFile = null;
      }
    }

    final copyName = '${product.name} (copy)';
    final data = <String, dynamic>{
      'category': product.category.id,
      'name': copyName,
      'variety': product.variety,
      'price_per_unit': product.pricePerUnit,
      'available_quantity': product.availableQuantity,
      'unit': product.unit,
      'harvest_date': product.harvestDate.toIso8601String().split('T').first,
      'shelf_life_days': product.shelfLifeDays,
      'is_organic': product.isOrganic,
      'description': product.description,
      'is_active': product.isActive,
      if (imageFile != null) 'image': imageFile,
    };
    if (!mounted) return;
    context.read<ProductBloc>().add(CreateProductEvent(data));
  }

  Future<void> _toggleActive(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.isActive ? 'Deactivate product' : 'Activate product'),
        content: Text(product.isActive
            ? 'Pause "${product.displayName}" so it stops appearing as active?'
            : 'Re-activate "${product.displayName}" for buyers to see it again?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(product.isActive ? 'Deactivate' : 'Activate')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final updated = {'is_active': !product.isActive};
    context.read<ProductBloc>().add(UpdateProductEvent(product.uuid, updated));
  }

  Future<void> _shareProduct(Product product) async {
    // Share using share_plus with a deep link (custom scheme or web URL)
    final url = 'https://mambonami.com/product/${product.uuid}';
    await Share.share(
      'Check out ${product.displayName} on MAMBONAMI! $url',
      subject: 'MAMBONAMI Product',
    );
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
            // Enhanced empty state with category placeholders
            return EmptyState(
              title: 'No products yet',
              description: 'Add your first product so buyers can discover your farm listings.',
              buttonText: 'Create product',
              onButtonPressed: _navigateToCreate,
              icon: Icons.agriculture_rounded,
            );
          }

          // ── Inventory Health ──────────────────────────────────────────
          final outOfStock = products.where((p) => p.availableQuantity <= 0).length;
          final lowStock = products.where((p) => p.isActive && p.availableQuantity > 0 && p.availableQuantity < 20).length;
          final healthy = products.where((p) => p.isActive && p.availableQuantity >= 20).length;
          final totalInventoryValue = products
              .where((p) => p.isActive)
              .fold<double>(0, (sum, p) => sum + p.pricePerUnit * p.availableQuantity);

          final visibleProducts = _filteredAndSortedProducts(products);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Inventory summary cards ─────────────────────────────
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
                    Row(
                      children: [
                        Expanded(
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
                              const SizedBox(height: 4),
                              Text(
                                'Track your catalog, status, and freshness in one place.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'KES ${totalInventoryValue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SummaryChip(label: '${products.length} listings', color: Colors.white.withValues(alpha: 0.25)),
                        _SummaryChip(label: '$healthy healthy', color: AppColors.success),
                        _SummaryChip(label: '$lowStock low stock', color: AppColors.warning),
                        _SummaryChip(label: '$outOfStock out', color: AppColors.error),
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

              // ── Filter chips + Sort menu ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filterOptions.map((filter) {
                            final selected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(filter),
                                selected: selected,
                                onSelected: (_) => setState(() => _selectedFilter = filter),
                                selectedColor: AppColors.primary.withValues(alpha: 0.16),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: selected ? AppColors.primary : AppColors.muted,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort_rounded),
                      onSelected: (value) => setState(() => _sortBy = value),
                      itemBuilder: (context) => _sortOptions.map((option) => PopupMenuItem(
                        value: option,
                        child: Row(
                          children: [
                            if (_sortBy == option) const Icon(Icons.check, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(option),
                          ],
                        ),
                      )).toList(),
                    ),
                    const SizedBox(width: 8),
                  ],
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
                            childAspectRatio: 0.60,
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
                              onDuplicate: () => _duplicateProduct(product),
                              onDeactivate: () => _toggleActive(product),
                              onShare: () => _shareProduct(product),
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

  // Placeholder icon with emoji based on common categories
  Widget _buildCategoryPlaceholder() {
    return const Icon(
      Icons.agriculture_rounded,
      size: 80,
      color: AppColors.primary,
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