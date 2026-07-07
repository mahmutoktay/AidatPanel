import '../../dekont/domain/entities/dekont_entity.dart';
import '../../dekont/domain/entities/dekont_status.dart';
import 'entities/due_entity.dart';
import 'entities/due_transaction_entity.dart';

/// Sakin işlem geçmişi — `/me/dues` + `/me/dekonts` client-side birleştirme.
List<DueTransactionEntity> mergeResidentDueTransactions({
  required List<DueEntity> dues,
  required List<DekontEntity> dekonts,
}) {
  final paymentRows = _paymentRowsFromDues(dues, dekonts);
  final dekontRows = _dekontRows(dekonts);

  final merged = [...paymentRows, ...dekontRows];
  merged.sort((a, b) {
    final diff = b.occurredAt.compareTo(a.occurredAt);
    if (diff != 0) return diff;
    return b.id.compareTo(a.id);
  });
  return merged;
}

List<DueTransactionEntity> _paymentRowsFromDues(
  List<DueEntity> dues,
  List<DekontEntity> dekonts,
) {
  final receiptDueIds = {
    for (final dekont in dekonts)
      if (dekont.dueId != null &&
          (dekont.status == DekontStatus.paymentApplied ||
              dekont.status == DekontStatus.paymentPartial))
        dekont.dueId!,
  };

  return [
    for (final due in dues)
      if (due.status == DueStatus.paid && due.paidAt != null)
        DueTransactionEntity(
          id: 'payment-${due.id}',
          kind: DueTransactionKind.payment,
          source: receiptDueIds.contains(due.id)
              ? DueTransactionSource.receipt
              : DueTransactionSource.manual,
          amount: due.amount,
          currency: due.currency,
          occurredAt: due.paidAt!,
          apartmentNumber: due.apartmentNumber,
          residentName: due.resident?.name,
          status: DueTransactionStatus.approved,
          dekontId: _dekontIdForDue(dekonts, due.id),
          dueId: due.id,
        ),
  ];
}

String? _dekontIdForDue(List<DekontEntity> dekonts, String dueId) {
  for (final dekont in dekonts) {
    if (dekont.dueId == dueId &&
        (dekont.status == DekontStatus.paymentApplied ||
            dekont.status == DekontStatus.paymentPartial)) {
      return dekont.id;
    }
  }
  return null;
}

List<DueTransactionEntity> _dekontRows(List<DekontEntity> dekonts) {
  return [
    for (final dekont in dekonts)
      if (_shouldIncludeDekont(dekont))
        DueTransactionEntity(
          id: dekont.id,
          kind: DueTransactionKind.dekont,
          source: DueTransactionSource.receipt,
          amount: _parseAmount(dekont.parsedAmount),
          currency: 'TRY',
          occurredAt: dekont.transactionDate ?? dekont.createdAt,
          apartmentNumber: dekont.apartment?.number,
          residentName: dekont.uploadedBy?.name,
          status: _mapDekontStatus(dekont.status),
          dekontId: dekont.id,
          dueId: dekont.dueId,
        ),
  ];
}

bool _shouldIncludeDekont(DekontEntity dekont) {
  switch (dekont.status) {
    case DekontStatus.rejected:
      return true;
    case DekontStatus.paymentApplied:
    case DekontStatus.paymentPartial:
      return false;
    default:
      return true;
  }
}

DueTransactionStatus _mapDekontStatus(DekontStatus status) {
  if (status == DekontStatus.rejected) {
    return DueTransactionStatus.rejected;
  }
  return DueTransactionStatus.pending;
}

double? _parseAmount(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return double.tryParse(value.replaceAll(',', '.'));
}
