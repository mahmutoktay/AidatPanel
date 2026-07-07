import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dekont/presentation/providers/dekont_provider.dart';
import '../../domain/entities/due_transaction_entity.dart';
import '../../domain/resident_due_transactions.dart';
import 'dues_provider.dart';

class ResidentDueTransactionsViewState {
  final bool isLoading;
  final List<DueTransactionEntity> transactions;
  final String? error;

  const ResidentDueTransactionsViewState({
    this.isLoading = false,
    this.transactions = const [],
    this.error,
  });
}

final residentDueTransactionsProvider =
    Provider<ResidentDueTransactionsViewState>((ref) {
  final duesState = ref.watch(duesNotifierProvider);
  final dekontsState = ref.watch(myDekontsNotifierProvider);

  final isLoading =
      (duesState.isLoading && duesState.dues.isEmpty) ||
      (dekontsState.isLoading && dekontsState.dekonts.isEmpty);

  final error = duesState.error ?? dekontsState.error;

  if (isLoading) {
    return ResidentDueTransactionsViewState(isLoading: true, error: error);
  }

  final transactions = mergeResidentDueTransactions(
    dues: duesState.dues,
    dekonts: dekontsState.dekonts,
  );

  return ResidentDueTransactionsViewState(
    transactions: transactions,
    error: error,
  );
});
