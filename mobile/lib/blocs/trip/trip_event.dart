// mobile/lib/blocs/trip/trip_event.dart
part of 'trip_bloc.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();
  @override List<Object?> get props => [];
}

class FetchAvailableOrdersEvent extends TripEvent {}

class AssignOrderEvent extends TripEvent {
  final int orderId;
  const AssignOrderEvent(this.orderId);
  @override List<Object> get props => [orderId];
}

class FetchMyTripsEvent extends TripEvent {}

class FetchTripDetailEvent extends TripEvent {
  final String tripUuid;
  const FetchTripDetailEvent(this.tripUuid);
  @override List<Object> get props => [tripUuid];
}

class MarkPickupEvent extends TripEvent {
  final String tripUuid;
  final double? latitude;
  final double? longitude;
  final String? photoPath;
  const MarkPickupEvent({required this.tripUuid, this.latitude, this.longitude, this.photoPath});
  @override List<Object?> get props => [tripUuid, latitude, longitude, photoPath];
}

class MarkDeliveryEvent extends TripEvent {
  final String tripUuid;
  final double? latitude;
  final double? longitude;
  final String? photoPath;
  const MarkDeliveryEvent({required this.tripUuid, this.latitude, this.longitude, this.photoPath});
  @override List<Object?> get props => [tripUuid, latitude, longitude, photoPath];
}

class ArriveAtFarmEvent extends TripEvent {
  final String tripUuid;
  const ArriveAtFarmEvent(this.tripUuid);
  @override List<Object> get props => [tripUuid];
}

class GenerateOtpEvent extends TripEvent {
  final String tripUuid;
  const GenerateOtpEvent(this.tripUuid);
  @override List<Object> get props => [tripUuid];
}

class VerifyOtpEvent extends TripEvent {
  final String tripUuid;
  final String otp;
  const VerifyOtpEvent(this.tripUuid, this.otp);
  @override List<Object> get props => [tripUuid, otp];
}

class VerifyDeliveryOtpEvent extends TripEvent {
  final String orderId;
  final String otp;
  const VerifyDeliveryOtpEvent({required this.orderId, required this.otp});
  @override List<Object> get props => [orderId, otp];
}