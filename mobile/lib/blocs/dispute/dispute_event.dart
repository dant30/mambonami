part of 'dispute_bloc.dart';

abstract class DisputeEvent extends Equatable {
  const DisputeEvent();

  @override
  List<Object?> get props => [];
}

// ============ DISPUTE EVENTS ============
class FetchMyDisputesEvent extends DisputeEvent {
  const FetchMyDisputesEvent();
}

class FetchDisputeDetailEvent extends DisputeEvent {
  final String uuid;

  const FetchDisputeDetailEvent(this.uuid);

  @override
  List<Object?> get props => [uuid];
}

class CreateDisputeEvent extends DisputeEvent {
  final CreateDisputeRequest request;

  const CreateDisputeEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class ResolveDisputeEvent extends DisputeEvent {
  final ResolveDisputeRequest request;

  const ResolveDisputeEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class ClearDisputeEvent extends DisputeEvent {
  const ClearDisputeEvent();
}
