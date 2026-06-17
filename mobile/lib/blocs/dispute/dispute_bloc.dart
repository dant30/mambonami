import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/dispute_repository.dart';
import '../../data/models/dispute.dart';

part 'dispute_event.dart';
part 'dispute_state.dart';

class DisputeBloc extends Bloc<DisputeEvent, DisputeState> {
  final DisputeRepository disputeRepository;

  DisputeBloc({required this.disputeRepository}) : super(const DisputeInitial()) {
    on<FetchMyDisputesEvent>(_onFetchMyDisputes);
    on<FetchDisputeDetailEvent>(_onFetchDisputeDetail);
    on<CreateDisputeEvent>(_onCreateDispute);
    on<ResolveDisputeEvent>(_onResolveDispute);
    on<ClearDisputeEvent>(_onClearDispute);
  }

  Future<void> _onFetchMyDisputes(
    FetchMyDisputesEvent event,
    Emitter<DisputeState> emit,
  ) async {
    emit(const DisputeLoading());
    try {
      final disputes = await disputeRepository.fetchMyDisputes();
      emit(MyDisputesLoaded(disputes));
    } catch (e) {
      emit(DisputeError(e.toString()));
    }
  }

  Future<void> _onFetchDisputeDetail(
    FetchDisputeDetailEvent event,
    Emitter<DisputeState> emit,
  ) async {
    emit(const DisputeLoading());
    try {
      final disputeResponse = await disputeRepository.fetchDisputeDetail(event.uuid);
      final dispute = _responseToDomain(disputeResponse);
      emit(DisputeDetailLoaded(dispute));
    } catch (e) {
      emit(DisputeError(e.toString()));
    }
  }

  Future<void> _onCreateDispute(
    CreateDisputeEvent event,
    Emitter<DisputeState> emit,
  ) async {
    emit(const DisputeLoading());
    try {
      final disputeResponse = await disputeRepository.createDispute(event.request);
      final dispute = _responseToDomain(disputeResponse);
      emit(DisputeCreated(dispute));
    } catch (e) {
      emit(DisputeError(e.toString()));
    }
  }

  Future<void> _onResolveDispute(
    ResolveDisputeEvent event,
    Emitter<DisputeState> emit,
  ) async {
    emit(const DisputeLoading());
    try {
      final disputeResponse = await disputeRepository.resolveDispute(event.request);
      final dispute = _responseToDomain(disputeResponse);
      emit(DisputeResolved(dispute));
    } catch (e) {
      emit(DisputeError(e.toString()));
    }
  }

  Future<void> _onClearDispute(
    ClearDisputeEvent event,
    Emitter<DisputeState> emit,
  ) async {
    emit(const DisputeInitial());
  }

  // ============ PRIVATE HELPER ============
  Dispute _responseToDomain(DisputeResponse response) {
    return Dispute(
      uuid: response.uuid,
      orderUuid: response.orderUuid,
      subject: response.subject,
      description: response.description,
      status: response.status,
      resolution: response.resolution,
      attachmentUrls: response.attachmentUrls,
      createdAt: response.createdAt,
      resolvedAt: response.resolvedAt,
      updatedAt: response.updatedAt,
    );
  }
}
