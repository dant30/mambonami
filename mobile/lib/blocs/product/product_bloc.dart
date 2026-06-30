import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class _FavoriteTracker {
  static final Set<String> _favoriteIds = <String>{};

  static bool isFavorite(Product product) => _favoriteIds.contains(product.uuid);

  static void toggle(Product product) {
    if (_favoriteIds.contains(product.uuid)) {
      _favoriteIds.remove(product.uuid);
    } else {
      _favoriteIds.add(product.uuid);
    }
  }
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  static bool isFavorite(Product product) => _FavoriteTracker.isFavorite(product);

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<FetchProductDetailEvent>(_onFetchProductDetail);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Product _syncFavorite(Product product) =>
      product.copyWith(isFavorite: _FavoriteTracker.isFavorite(product));

  List<Product> _syncFavorites(List<Product> products) =>
      products.map(_syncFavorite).toList();

  Future<void> _onFetchProducts(FetchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    // Emit cached products immediately if available, then refresh
    try {
      final cached = await productRepository.getCachedProducts(
        categoryCode: event.categoryCode,
        farmerId: event.farmerId,
      );
      if (cached.isNotEmpty) {
        emit(ProductLoaded(_syncFavorites(cached)));
      }
    } catch (_) {}

    try {
      final products = await productRepository.getProducts(
        categoryCode: event.categoryCode,
        farmerId: event.farmerId,
      );
      emit(ProductLoaded(_syncFavorites(products)));
    } catch (e) {
      // If we already emitted cached list above, avoid replacing with an error
      if (state is! ProductLoaded) {
        emit(ProductError(e.toString()));
      }
    }
  }

  Future<void> _onFetchProductDetail(FetchProductDetailEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await productRepository.getProductByUuid(event.uuid);
      emit(ProductDetailLoaded(_syncFavorite(product)));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onCreateProduct(CreateProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await productRepository.createProduct(event.data);
      emit(ProductCreated(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(UpdateProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await productRepository.updateProduct(event.uuid, event.data);
      emit(ProductUpdated(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      await productRepository.deleteProduct(event.uuid);
      emit(ProductDeleted());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(ToggleFavoriteEvent event, Emitter<ProductState> emit) async {
    _FavoriteTracker.toggle(event.product);
    final updatedProduct = event.product.copyWith(isFavorite: _FavoriteTracker.isFavorite(event.product));

    if (state is ProductLoaded) {
      final currentProducts = (state as ProductLoaded).products.map((product) {
        return product.uuid == updatedProduct.uuid ? updatedProduct : product;
      }).toList();
      emit(ProductLoaded(currentProducts));
      return;
    }

    if (state is ProductDetailLoaded) {
      final currentDetail = (state as ProductDetailLoaded).product;
      if (currentDetail.uuid == updatedProduct.uuid) {
        emit(ProductDetailLoaded(updatedProduct));
      }
    }
  }
}