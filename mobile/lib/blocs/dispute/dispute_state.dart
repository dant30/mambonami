part of 'dispute_bloc.dart';

// ============ DISPUTE STATES ============
abstract class DisputeState extends Equatable {
  const DisputeState();

  @override
  List<Object?> get props => [];
}

class DisputeInitial extends DisputeState {
  const DisputeInitial();
}

class DisputeLoading extends DisputeState {
  const DisputeLoading();
}

class MyDisputesLoaded extends DisputeState {
  final List<Dispute> disputes;

  const MyDisputesLoaded(this.disputes);

  @override
  List<Object?> get props => [disputes];
}

class DisputeDetailLoaded extends DisputeState {
  final Dispute dispute;

  const DisputeDetailLoaded(this.dispute);

  @override
  List<Object?> get props => [dispute];
}

class DisputeCreated extends DisputeState {
  final Dispute dispute;

  const DisputeCreated(this.dispute);

  @override
  List<Object?> get props => [dispute];
}

class DisputeResolved extends DisputeState {
  final Dispute dispute;

  const DisputeResolved(this.dispute);

  @override
  List<Object?> get props => [dispute];
}

class DisputeError extends DisputeState {
  final String message;

  const DisputeError(this.message);

  @override
  List<Object?> get props => [message];
}
