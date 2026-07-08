import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/due_transaction_entity.dart';
import 'dues_provider.dart';

typedef DuePaymentDetailKey = ({String buildingId, String dueId});

/// Tek bir aidat kaydına ait ödeme/işlem detayı (dekont veya manuel).
final duePaymentDetailProvider = FutureProvider.autoDispose
    .family<DueTransactionEntity?, DuePaymentDetailKey>((ref, key) async {
  final repo = ref.read(duesRepositoryProvider);
  final result = await repo.getDueTransactions(
    key.buildingId,
    paginated: false,
  );

  DueTransactionEntity? approved;
  DueTransactionEntity? pendingOrRejected;

  for (final transaction in result.items) {
    if (transaction.dueId != key.dueId) continue;

    if (transaction.status == DueTransactionStatus.approved) {
      approved = transaction;
      break;
    }
    pendingOrRejected ??= transaction;
  }

  return approved ?? pendingOrRejected;
});
