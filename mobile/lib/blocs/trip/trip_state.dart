// mobile/lib/blocs/trip/trip_state.dart
part of 'trip_bloc.dart';

abstract class TripState extends Equatable {
  const TripState();
  @override List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class AvailableOrdersLoaded extends TripState {
  final List<Trip> orders;
  const AvailableOrdersLoaded(this.orders);
  @override List<Object> get props => [orders];
}

class MyTripsLoaded extends TripState {
  final List<Trip> trips;
  const MyTripsLoaded(this.trips);
  @override List<Object> get props => [trips];
}

class TripDetailLoaded extends TripState {
  final Trip trip;
  const TripDetailLoaded(this.trip);
  @override List<Object> get props => [trip];
}

class TripAssigned extends TripState {
  final Trip trip;
  const TripAssigned(this.trip);
  @override List<Object> get props => [trip];
}

class PickupMarked extends TripState {
  final Trip trip;
  const PickupMarked(this.trip);
  @override List<Object> get props => [trip];
}

class DeliveryMarked extends TripState {
  final Trip trip;
  const DeliveryMarked(this.trip);
  @override List<Object> get props => [trip];
}

class ArriveAtFarmSuccess extends TripState {
  final TripArriveResponse response;
  const ArriveAtFarmSuccess(this.response);
  @override List<Object?> get props => [response.message, response.arrivedAt, response.waitingGraceMinutes];
}

class OtpGenerated extends TripState {
  final String otp;
  final int expiresIn;
  const OtpGenerated(this.otp, this.expiresIn);
  @override List<Object> get props => [otp, expiresIn];
}

class DeliveryConfirmed extends TripState {}

class TripError extends TripState {
  final String message;
  const TripError(this.message);
  @override List<Object> get props => [message];
}