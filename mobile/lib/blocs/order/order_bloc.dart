import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/dtos/order_dto.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/models/order.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    // Buyer
    on<CreateOrderEvent>(_onCreateOrder);
    on<FetchMyOrdersEvent>(_onFetchMyOrders);
    on<FetchOrderDetailEvent>(_onFetchOrderDetail);
    // Farmer
    on<FetchFarmerSubOrdersEvent>(_onFetchFarmerSubOrders);
    on<ConfirmSubOrderEvent>(_onConfirmSubOrder);
    on<MarkSubOrderReadyEvent>(_onMarkSubOrderReady);
    // Transport provider
    on<FetchAvailableOrdersEvent>(_onFetchAvailableOrders);
    on<AssignToOrderEvent>(_onAssignToOrder);
    on<GenerateOTPEvent>(_onGenerateOTP);
    on<VerifyOTPEvent>(_onVerifyOTP);
  }

  Future<void> _onCreateOrder(CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final result = await orderRepository.createOrder(event.request);
      emit(OrderCreated(result));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onFetchMyOrders(FetchMyOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await orderRepository.fetchMyOrders();
      emit(MyOrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onFetchOrderDetail(FetchOrderDetailEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await orderRepository.fetchOrderDetail(event.uuid);
      emit(OrderDetailLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onFetchFarmerSubOrders(FetchFarmerSubOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final subOrders = await orderRepository.fetchFarmerSubOrders();
      emit(FarmerSubOrdersLoaded(subOrders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onConfirmSubOrder(ConfirmSubOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      await orderRepository.confirmSubOrder(event.subOrderId);
      emit(SubOrderConfirmed(event.subOrderId));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onMarkSubOrderReady(MarkSubOrderReadyEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      await orderRepository.markSubOrderReady(event.subOrderId);
      emit(SubOrderReady(event.subOrderId));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onFetchAvailableOrders(FetchAvailableOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await orderRepository.fetchAvailableOrders();
      emit(AvailableOrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onAssignToOrder(AssignToOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      await orderRepository.assignToOrder(event.orderId);
      emit(OrderAssigned(event.orderId));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onGenerateOTP(GenerateOTPEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final otp = await orderRepository.generateOTP(event.tripUuid);
      emit(OTPGenerated(otp));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onVerifyOTP(VerifyOTPEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      await orderRepository.verifyOTP(event.tripUuid, event.otp);
      emit(OTPVerified());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}