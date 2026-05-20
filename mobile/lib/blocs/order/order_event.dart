part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override List<Object?> get props => [];
}

// Buyer events
class CreateOrderEvent extends OrderEvent {
  final CreateOrderRequest request;
  const CreateOrderEvent(this.request);
  @override List<Object> get props => [request];
}

class FetchMyOrdersEvent extends OrderEvent {}
class FetchOrderDetailEvent extends OrderEvent {
  final String uuid;
  const FetchOrderDetailEvent(this.uuid);
  @override List<Object> get props => [uuid];
}

// Farmer events
class FetchFarmerSubOrdersEvent extends OrderEvent {}
class ConfirmSubOrderEvent extends OrderEvent {
  final int subOrderId;
  const ConfirmSubOrderEvent(this.subOrderId);
  @override List<Object> get props => [subOrderId];
}
class MarkSubOrderReadyEvent extends OrderEvent {
  final int subOrderId;
  const MarkSubOrderReadyEvent(this.subOrderId);
  @override List<Object> get props => [subOrderId];
}

// Transport provider events
class FetchAvailableOrdersEvent extends OrderEvent {}
class AssignToOrderEvent extends OrderEvent {
  final int orderId;
  const AssignToOrderEvent(this.orderId);
  @override List<Object> get props => [orderId];
}
class GenerateOTPEvent extends OrderEvent {
  final String tripUuid;
  const GenerateOTPEvent(this.tripUuid);
}
class VerifyOTPEvent extends OrderEvent {
  final String tripUuid;
  final String otp;
  const VerifyOTPEvent(this.tripUuid, this.otp);
}