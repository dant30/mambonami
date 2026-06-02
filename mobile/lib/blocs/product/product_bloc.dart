import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<FetchProductDetailEvent>(_onFetchProductDetail);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onFetchProducts(FetchProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    // Emit cached products immediately if available, then refresh
    try {
      final cached = await productRepository.getCachedProducts(
        categoryCode: event.categoryCode,
        farmerId: event.farmerId,
      );
      if (cached.isNotEmpty) {
        emit(ProductLoaded(cached));
      }
    } catch (_) {}

    try {
      final products = await productRepository.getProducts(
        categoryCode: event.categoryCode,
        farmerId: event.farmerId,
      );
      emit(ProductLoaded(products));
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
      emit(ProductDetailLoaded(product));
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
}