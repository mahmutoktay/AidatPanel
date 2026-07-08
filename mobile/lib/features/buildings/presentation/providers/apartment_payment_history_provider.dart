import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/domain/entities/due_transaction_entity.dart';
import '../../../dues/domain/resident_dues_list.dart';
import '../../../dues/presentation/providers/dues_provider.dart';

class ApartmentPaymentHistoryItem extends Equatable {
  final DueEntity due;
  final DueTransactionSource? paymentSource;
  final DueTransactionStatus? transactionStatus;

  const ApartmentPaymentHistoryItem({
    required this.due,
    this.paymentSource,
    this.transactionStatus,
  });

  @override
  List<Object?> get props => [due, paymentSource, transactionStatus];
}

typedef ApartmentPaymentHistoryKey = ({String buildingId, String apartmentId});

/// Daireye ait tüm geçmiş dönem aidatları ve ödeme kaynakları.
final apartmentPaymentHistoryProvider = FutureProvider.autoDispose
    .family<List<ApartmentPaymentHistoryItem>, ApartmentPaymentHistoryKey>((
  ref,
  key,
) async {
  final repo = ref.read(duesRepositoryProvider);

  final duesResult = await repo.getBuildingDues(
    key.buildingId,
    paginated: false,
  );
  final apartmentDues = duesResult.items
      .where((due) => due.apartmentId == key.apartmentId)
      .where((due) => isDuePeriodAtOrBeforeNow(due.month, due.year, DateTime.now()))
      .toList(growable: false)
    ..sort((a, b) {
      final yearCompare = b.year.compareTo(a.year);
      if (yearCompare != 0) return yearCompare;
      return b.month.compareTo(a.month);
    });

  final transactionsResult = await repo.getDueTransactions(
    key.buildingId,
    paginated: false,
  );
  final transactionsByDueId = _transactionsByDueId(transactionsResult.items);

  return apartmentDues
      .map((due) {
        final transaction = transactionsByDueId[due.id];
        return ApartmentPaymentHistoryItem(
          due: due,
          paymentSource: _resolvePaymentSource(due, transaction),
          transactionStatus: transaction?.status,
        );
      })
      .toList(growable: false);
});

Map<String, DueTransactionEntity> _transactionsByDueId(
  List<DueTransactionEntity> transactions,
) {
  final map = <String, DueTransactionEntity>{};
  for (final transaction in transactions) {
    final dueId = transaction.dueId;
    if (dueId == null) continue;

    final existing = map[dueId];
    if (existing == null) {
      map[dueId] = transaction;
      continue;
    }
    if (transaction.status == DueTransactionStatus.approved) {
      map[dueId] = transaction;
    }
  }
  return map;
}

DueTransactionSource? _resolvePaymentSource(
  DueEntity due,
  DueTransactionEntity? transaction,
) {
  if (due.status != DueStatus.paid && due.status != DueStatus.waived) {
    return null;
  }
  if (transaction == null) return null;
  if (transaction.kind == DueTransactionKind.dekont ||
      transaction.source == DueTransactionSource.receipt) {
    return DueTransactionSource.receipt;
  }
  return DueTransactionSource.manual;
}
