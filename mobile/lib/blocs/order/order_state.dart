part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  @override List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

// Buyer states
class OrderCreated extends OrderState {
  final Map<String, dynamic> paymentInfo;
  const OrderCreated(this.paymentInfo);
  @override List<Object> get props => [paymentInfo];
}
class MyOrdersLoaded extends OrderState {
  final List<Order> orders;
  const MyOrdersLoaded(this.orders);
}
class BuyerOrdersLoaded extends OrderState {
  final List<Order> orders;
  final Order? activeOrder;
  const BuyerOrdersLoaded(this.orders, {this.activeOrder});
}
class OrderDetailLoaded extends OrderState {
  final Order order;
  const OrderDetailLoaded(this.order);
}

// Farmer states
class FarmerSubOrdersLoaded extends OrderState {
  final List<SubOrder> subOrders;
  const FarmerSubOrdersLoaded(this.subOrders);
}
class SubOrderConfirmed extends OrderState {
  final int subOrderId;
  const SubOrderConfirmed(this.subOrderId);
}
class SubOrderReady extends OrderState {
  final int subOrderId;
  const SubOrderReady(this.subOrderId);
}

class SubOrderDeclined extends OrderState {
  final int subOrderId;
  const SubOrderDeclined(this.subOrderId);
}

// Transport provider states
class AvailableOrdersLoaded extends OrderState {
  final List<Order> orders;
  const AvailableOrdersLoaded(this.orders);
}
class OrderAssigned extends OrderState {
  final int orderId;
  const OrderAssigned(this.orderId);
}
class OTPGenerated extends OrderState {
  final String otp;
  const OTPGenerated(this.otp);
}
class OTPVerified extends OrderState {}

// Error
class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
}