import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/domain/entities/due_transaction_entity.dart';
import '../../../dues/domain/resident_dues_list.dart';
import '../../../dues/presentation/providers/dues_provider.dart';

class ApartmentDueHistoryItem extends Equatable {
  final DueEntity due;
  final DueTransactionSource? paymentSource;

  const ApartmentDueHistoryItem({
    required this.due,
    this.paymentSource,
  });

  @override
  List<Object?> get props => [due, paymentSource];
}

typedef ApartmentDuesHistoryKey = ({String buildingId, String apartmentId});

/// Daireye ait tüm aidat dönemleri + ödeme kanalı (dekont/havale veya elden).
final apartmentDuesHistoryProvider = FutureProvider.autoDispose
    .family<List<ApartmentDueHistoryItem>, ApartmentDuesHistoryKey>((
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
      .where(shouldShowInAccountSummary)
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
  final paymentByDueId = _paymentSourcesByDueId(transactionsResult.items);

  return apartmentDues
      .map(
        (due) => ApartmentDueHistoryItem(
          due: due,
          paymentSource: _resolvePaymentSource(due, paymentByDueId),
        ),
      )
      .toList(growable: false);
});

Map<String, DueTransactionSource> _paymentSourcesByDueId(
  List<DueTransactionEntity> transactions,
) {
  final map = <String, DueTransactionSource>{};

  for (final transaction in transactions) {
    final dueId = transaction.dueId;
    if (dueId == null || transaction.status != DueTransactionStatus.approved) {
      continue;
    }

    final source = _transactionPaymentSource(transaction);
    final existing = map[dueId];
    if (existing == null || source == DueTransactionSource.receipt) {
      map[dueId] = source;
    }
  }

  return map;
}

DueTransactionSource _transactionPaymentSource(DueTransactionEntity transaction) {
  if (transaction.kind == DueTransactionKind.dekont ||
      transaction.source == DueTransactionSource.receipt) {
    return DueTransactionSource.receipt;
  }
  return DueTransactionSource.manual;
}

DueTransactionSource? _resolvePaymentSource(
  DueEntity due,
  Map<String, DueTransactionSource> paymentByDueId,
) {
  if (due.status != DueStatus.paid && due.status != DueStatus.waived) {
    return null;
  }
  return paymentByDueId[due.id];
}
