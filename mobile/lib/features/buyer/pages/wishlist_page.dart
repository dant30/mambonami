import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/product/product_bloc.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/product_grid_tile.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const FetchWishlistEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wishlist'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(RoutePaths.buyerDashboard),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading || state is ProductInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is ProductError) {
            return Center(child: Text(state.message));
          }
          if (state is ProductLoaded) {
            final products = state.products
                .where((product) => product.isFavorite)
                .toList();
            if (products.isEmpty) {
              return const EmptyState(
                emoji: '♡',
                title: 'Your wishlist is empty',
                subtitle: 'Tap the heart on a product to save it here.',
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  ProductGridTile(product: products[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
