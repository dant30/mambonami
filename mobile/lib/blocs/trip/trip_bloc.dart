import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/trip_repository.dart';
import '../../data/dtos/trip_dto.dart';
import '../../data/models/trip.dart';

part 'trip_event.dart';
part 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository tripRepository;

  TripBloc({required this.tripRepository}) : super(TripInitial()) {
    on<FetchAvailableOrdersEvent>(_onFetchAvailableOrders);
    on<AssignOrderEvent>(_onAssignOrder);
    on<FetchMyTripsEvent>(_onFetchMyTrips);
    on<FetchTripDetailEvent>(_onFetchTripDetail);
    on<MarkPickupEvent>(_onMarkPickup);
    on<GenerateOtpEvent>(_onGenerateOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
  }

  Future<void> _onFetchAvailableOrders(FetchAvailableOrdersEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final orders = await tripRepository.getAvailableOrders();
      emit(AvailableOrdersLoaded(orders));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onAssignOrder(AssignOrderEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await tripRepository.assignToMe(event.orderId);
      emit(TripAssigned(trip));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onFetchMyTrips(FetchMyTripsEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trips = await tripRepository.getMyTrips();
      emit(MyTripsLoaded(trips));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onFetchTripDetail(FetchTripDetailEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await tripRepository.getTripDetail(event.tripUuid);
      emit(TripDetailLoaded(trip));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onMarkPickup(MarkPickupEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final dto = TripPickupDto(
        latitude: event.latitude,
        longitude: event.longitude,
        photoPath: event.photoPath,
      );
      final trip = await tripRepository.markPickup(event.tripUuid, dto);
      emit(PickupMarked(trip));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onGenerateOtp(GenerateOtpEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final result = await tripRepository.generateOtp(event.tripUuid);
      emit(OtpGenerated(result.otp, result.expiresIn));
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      await tripRepository.verifyOtp(event.tripUuid, event.otp);
      emit(DeliveryConfirmed());
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }
}