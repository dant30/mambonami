part of 'order_tracking_bloc.dart';

abstract class OrderTrackingState {}

class OrderTrackingInitial extends OrderTrackingState {}
class OrderTrackingLoading extends OrderTrackingState {}

class OrderTrackingLoaded extends OrderTrackingState {
  final Order order;
  OrderTrackingLoaded(this.order);
}

class OrderTrackingError extends OrderTrackingState {
  final String message;
  OrderTrackingError(this.message);
}
