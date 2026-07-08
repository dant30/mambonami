part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override List<Object?> get props => [];
}

class FetchProductsEvent extends ProductEvent {
  final String? categoryCode;
  final int? farmerId;
  const FetchProductsEvent({this.categoryCode, this.farmerId});
  @override List<Object?> get props => [categoryCode, farmerId];
}

class FetchProductDetailEvent extends ProductEvent {
  final String uuid;
  const FetchProductDetailEvent(this.uuid);
  @override List<Object> get props => [uuid];
}

class CreateProductEvent extends ProductEvent {
  final Map<String, dynamic> data;
  const CreateProductEvent(this.data);
  @override List<Object> get props => [data];
}

class UpdateProductEvent extends ProductEvent {
  final String uuid;
  final Map<String, dynamic> data;
  const UpdateProductEvent(this.uuid, this.data);
  @override List<Object> get props => [uuid, data];
}

class DeleteProductEvent extends ProductEvent {
  final String uuid;
  const DeleteProductEvent(this.uuid);
  @override List<Object> get props => [uuid];
}

class ToggleFavoriteEvent extends ProductEvent {
  final Product product;
  const ToggleFavoriteEvent(this.product);
  @override List<Object> get props => [product.uuid];
}

class SearchProductsEvent extends ProductEvent {
  final String query;
  const SearchProductsEvent({required this.query});
  @override List<Object> get props => [query];
}

class FilterProductsByCategoryEvent extends ProductEvent {
  final String category;
  const FilterProductsByCategoryEvent({required this.category});
  @override List<Object> get props => [category];
}

class SortProductsEvent extends ProductEvent {
  final String sortBy;
  const SortProductsEvent({required this.sortBy});
  @override List<Object> get props => [sortBy];
}