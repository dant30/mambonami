// mobile/lib/blocs/trip/trip_event.dart
part of 'trip_bloc.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();
  @override List<Object?> get props => [];
}

class FetchAvailableOrdersEvent extends TripEvent {}

class AssignOrderEvent extends TripEvent {
  final String tripUuid;
  const AssignOrderEvent(this.tripUuid);
  @override List<Object> get props => [tripUuid];
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

