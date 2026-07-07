import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/due_transaction_entity.dart';
import '../../domain/repositories/dues_repository.dart';
import 'dues_provider.dart';

class DueTransactionsState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<DueTransactionEntity> transactions;
  final String? nextCursor;
  final String? error;
  final String? buildingId;

  const DueTransactionsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.transactions = const [],
    this.nextCursor,
    this.error,
    this.buildingId,
  });

  bool get canLoadMore => nextCursor != null && !isLoadingMore && !isLoading;

  DueTransactionsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<DueTransactionEntity>? transactions,
    String? nextCursor,
    String? error,
    String? buildingId,
    bool clearError = false,
    bool clearCursor = false,
  }) {
    return DueTransactionsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      transactions: transactions ?? this.transactions,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      error: clearError ? null : (error ?? this.error),
      buildingId: buildingId ?? this.buildingId,
    );
  }
}

class DueTransactionsNotifier extends Notifier<DueTransactionsState> {
  @override
  DueTransactionsState build() => const DueTransactionsState();

  DuesRepository get _repo => ref.read(duesRepositoryProvider);

  Future<void> loadBuilding(String buildingId) async {
    state = state.copyWith(
      isLoading: true,
      buildingId: buildingId,
      clearError: true,
      clearCursor: true,
      transactions: const [],
    );

    try {
      final result = await _repo.getDueTransactions(
        buildingId,
        paginated: true,
      );
      state = state.copyWith(
        isLoading: false,
        transactions: result.items,
        nextCursor: result.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _message(e),
      );
    }
  }

  Future<void> loadMore() async {
    final buildingId = state.buildingId;
    final cursor = state.nextCursor;
    if (buildingId == null || cursor == null || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final result = await _repo.getDueTransactions(
        buildingId,
        cursor: cursor,
        paginated: true,
      );
      state = state.copyWith(
        isLoadingMore: false,
        transactions: [...state.transactions, ...result.items],
        nextCursor: result.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: _message(e),
      );
    }
  }

  String _message(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'due_transactions_fetch_failed';
  }
}

final dueTransactionsNotifierProvider =
    NotifierProvider<DueTransactionsNotifier, DueTransactionsState>(
  DueTransactionsNotifier.new,
);
