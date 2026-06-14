import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/ticket_remote_datasource.dart';
import '../../data/repositories/ticket_repository_impl.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/repositories/ticket_repository.dart';

final ticketRemoteDataSourceProvider = Provider<TicketRemoteDataSource>((ref) {
  return TicketRemoteDataSourceImpl(dioClient: ref.watch(dioClientProvider));
});

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepositoryImpl(
    remoteDataSource: ref.watch(ticketRemoteDataSourceProvider),
  );
});

class TicketsState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<TicketEntity> tickets;
  final String? nextCursor;
  final String? error;

  const TicketsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.tickets = const [],
    this.nextCursor,
    this.error,
  });

  bool get canLoadMore =>
      nextCursor != null &&
      nextCursor!.isNotEmpty &&
      !isLoading &&
      !isLoadingMore;

  TicketsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<TicketEntity>? tickets,
    String? nextCursor,
    String? error,
    bool clearError = false,
    bool clearNextCursor = false,
  }) {
    return TicketsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      tickets: tickets ?? this.tickets,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TicketsNotifier extends Notifier<TicketsState> {
  TicketRepository get _repository => ref.read(ticketRepositoryProvider);  bool _isCreating = false;
  bool _isResidentList = true;
  String? _buildingId;

  @override
  TicketsState build() => const TicketsState();
  Future<void> loadMyTickets({bool refresh = true}) async {
    final effectiveRefresh = refresh || !_isResidentList;
    if (!effectiveRefresh && !state.canLoadMore) return;
    _isResidentList = true;
    _buildingId = null;
    state = state.copyWith(
      isLoading: effectiveRefresh,
      isLoadingMore: !effectiveRefresh,
      clearError: true,
      clearNextCursor: effectiveRefresh,
    );
    try {
      final result = await _repository.getMyTickets(
        cursor: effectiveRefresh ? null : state.nextCursor,
      );
      final merged = effectiveRefresh
          ? result.items
          : [...state.tickets, ...result.items];
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        tickets: merged,
        nextCursor: result.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: userFacingError(e),
      );
    }
  }

  Future<void> loadBuildingTickets(
    String buildingId, {
    bool refresh = true,
  }) async {
    final effectiveRefresh =
        refresh || _isResidentList || _buildingId != buildingId;
    if (!effectiveRefresh && !state.canLoadMore) return;
    _isResidentList = false;
    _buildingId = buildingId;
    state = state.copyWith(
      isLoading: effectiveRefresh,
      isLoadingMore: !effectiveRefresh,
      clearError: true,
      clearNextCursor: effectiveRefresh,
    );
    try {
      final result = await _repository.getBuildingTickets(
        buildingId,
        cursor: effectiveRefresh ? null : state.nextCursor,
      );
      final merged = effectiveRefresh
          ? result.items
          : [...state.tickets, ...result.items];
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        tickets: merged,
        nextCursor: result.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: userFacingError(e),
      );
    }
  }

  Future<void> loadMore() {
    if (_isResidentList) {
      return loadMyTickets(refresh: false);
    }
    final id = _buildingId;
    if (id == null || id.isEmpty) return Future.value();
    return loadBuildingTickets(id, refresh: false);
  }

  Future<bool> createTicket({
    required String apartmentId,
    required String title,
    required String description,
    required TicketCategory category,
  }) async {
    if (_isCreating) return false;
    _isCreating = true;
    try {
      final created = await _repository.createTicket(
        apartmentId: apartmentId,
        title: title,
        description: description,
        category: category,
      );
      state = state.copyWith(
        tickets: [created, ...state.tickets],
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return false;
    } finally {
      _isCreating = false;
    }
  }

  bool get isCreating => _isCreating;
}

final ticketsNotifierProvider =
    NotifierProvider<TicketsNotifier, TicketsState>(TicketsNotifier.new);
final ticketDetailProvider = FutureProvider.family<TicketEntity, String>((
  ref,
  ticketId,
) async {
  return ref.watch(ticketRepositoryProvider).getTicketById(ticketId);
});
