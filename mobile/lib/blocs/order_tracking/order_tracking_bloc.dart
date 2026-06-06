import 'package:flutter_bloc/flutter_bloc.dart';
// GetIt may be used by consumers; don't import here unless used
import '../../data/repositories/order_repository.dart';
import '../../data/models/order.dart';

part 'order_tracking_event.dart';
part 'order_tracking_state.dart';

class OrderTrackingBloc extends Bloc<OrderTrackingEvent, OrderTrackingState> {
  final OrderRepository orderRepository;
  // GetIt available via getIt if needed
  String? _currentUuid;

  OrderTrackingBloc({required this.orderRepository})
      : super(OrderTrackingInitial()) {
    on<FetchOrderTracking>(_onFetch);
    on<RefreshOrderTracking>(_onRefresh);
    on<NotificationAffectsOrder>(_onNotification);
  }

  Future<void> _onFetch(
      FetchOrderTracking event, Emitter<OrderTrackingState> emit) async {
    emit(OrderTrackingLoading());
    _currentUuid = event.uuid;
    try {
      final order = await orderRepository.fetchOrderDetail(event.uuid);
      emit(OrderTrackingLoaded(order));
    } catch (e) {
      emit(OrderTrackingError(e.toString()));
    }
  }

  Future<void> _onRefresh(
      RefreshOrderTracking event, Emitter<OrderTrackingState> emit) async {
    final uuid = _currentUuid;
    if (uuid == null) return;
    emit(OrderTrackingLoading());
    try {
      final order = await orderRepository.fetchOrderDetail(uuid);
      emit(OrderTrackingLoaded(order));
    } catch (e) {
      emit(OrderTrackingError(e.toString()));
    }
  }

  Future<void> _onNotification(
      NotificationAffectsOrder event, Emitter<OrderTrackingState> emit) async {
    final currentState = state;
    if (currentState is OrderTrackingLoaded) {
      final notif = event.notification;
      try {
        final meta = notif.metadata as Map<String, dynamic>;
        final orderUuid = meta['order_uuid'] ?? meta['order'];
        if (orderUuid != null && orderUuid == _currentUuid) {
          // Apply optimistic update if status present
          final status = meta['status'] as String?;
          if (status != null && status.isNotEmpty) {
            final updated = _copyWithStatus(currentState.order, status);
            emit(OrderTrackingLoaded(updated));
            return;
          }
          // otherwise refresh from backend to get full latest state
          add(RefreshOrderTracking());
        }
      } catch (_) {
        // ignore malformed metadata
      }
    }
  }

  Order _copyWithStatus(Order o, String status) {
    return Order(
      id: o.id,
      uuid: o.uuid,
      totalAmount: o.totalAmount,
      deliveryFee: o.deliveryFee,
      platformCommission: o.platformCommission,
      status: status,
      accountNumber: o.accountNumber,
      deliveryAddress: o.deliveryAddress,
      deliveryStreet: o.deliveryStreet,
      deliveryCity: o.deliveryCity,
      deliveryPostalCode: o.deliveryPostalCode,
      deliveryLandmark: o.deliveryLandmark,
      deliveryLat: o.deliveryLat,
      deliveryLng: o.deliveryLng,
      totalWeightKg: o.totalWeightKg,
      scheduledDate: o.scheduledDate,
      scheduledTimeWindow: o.scheduledTimeWindow,
      assignedProviderName: o.assignedProviderName,
      subOrders: o.subOrders,
      createdAt: o.createdAt,
    );
  }
}
