import 'package:aidatpanel/features/dekont/domain/entities/dekont_entity.dart';
import 'package:aidatpanel/features/dekont/domain/entities/dekont_status.dart';
import 'package:aidatpanel/features/dues/domain/entities/due_entity.dart';
import 'package:aidatpanel/features/dues/domain/entities/due_transaction_entity.dart';
import 'package:aidatpanel/features/dues/domain/resident_debt_summary.dart';
import 'package:aidatpanel/features/dues/domain/resident_due_transactions.dart';
import 'package:flutter_test/flutter_test.dart';

DueEntity _due({
  required String id,
  DueStatus status = DueStatus.pending,
  double amount = 100,
  DateTime? paidAt,
  int month = 7,
  int year = 2026,
}) {
  return DueEntity(
    id: id,
    apartmentId: 'apt-1',
    apartmentNumber: '3',
    amount: amount,
    currency: 'TRY',
    month: month,
    year: year,
    status: status,
    paidAt: paidAt,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 1),
  );
}

DekontEntity _dekont({
  required String id,
  DekontStatus status = DekontStatus.needsManagerReview,
  String? dueId,
  DateTime? createdAt,
}) {
  return DekontEntity(
    id: id,
    buildingId: 'b1',
    uploadedById: 'u1',
    dueId: dueId,
    status: status,
    source: 'upload',
    originalFilename: 'dekont.pdf',
    mimeType: 'application/pdf',
    sizeBytes: 100,
    createdAt: createdAt ?? DateTime(2026, 7, 2),
    updatedAt: createdAt ?? DateTime(2026, 7, 2),
  );
}

void main() {
  group('resident_debt_summary', () {
    test('totalOutstandingAmount sums pending and overdue only', () {
      final dues = [
        _due(id: '1', status: DueStatus.pending, amount: 100),
        _due(id: '2', status: DueStatus.overdue, amount: 50),
        _due(id: '3', status: DueStatus.paid, amount: 200),
        _due(id: '4', status: DueStatus.waived, amount: 75),
      ];

      expect(totalOutstandingAmount(dues), 150);
      expect(overdueDueCount(dues), 1);
      expect(hasOutstandingDebt(dues), isTrue);
    });

    test('hasOutstandingDebt is false when no open dues', () {
      final dues = [
        _due(id: '1', status: DueStatus.paid, paidAt: DateTime(2026, 7, 1)),
      ];

      expect(hasOutstandingDebt(dues), isFalse);
    });
  });

  group('mergeResidentDueTransactions', () {
    test('merges paid dues and pending dekonts sorted by date desc', () {
      final dues = [
        _due(
          id: 'due-1',
          status: DueStatus.paid,
          amount: 500,
          paidAt: DateTime(2026, 6, 10),
        ),
      ];
      final dekonts = [
        _dekont(
          id: 'dekont-1',
          createdAt: DateTime(2026, 7, 5),
        ),
      ];

      final merged = mergeResidentDueTransactions(dues: dues, dekonts: dekonts);

      expect(merged, hasLength(2));
      expect(merged.first.id, 'dekont-1');
      expect(merged.first.kind, DueTransactionKind.dekont);
      expect(merged.last.kind, DueTransactionKind.payment);
    });

    test('skips payment-applied dekont when due is already paid', () {
      final dues = [
        _due(
          id: 'due-1',
          status: DueStatus.paid,
          paidAt: DateTime(2026, 6, 10),
        ),
      ];
      final dekonts = [
        _dekont(
          id: 'dekont-1',
          status: DekontStatus.paymentApplied,
          dueId: 'due-1',
        ),
      ];

      final merged = mergeResidentDueTransactions(dues: dues, dekonts: dekonts);

      expect(merged, hasLength(1));
      expect(merged.single.kind, DueTransactionKind.payment);
      expect(merged.single.dekontId, 'dekont-1');
      expect(merged.single.source, DueTransactionSource.receipt);
    });

    test('includes rejected dekont rows', () {
      final merged = mergeResidentDueTransactions(
        dues: const [],
        dekonts: [
          _dekont(id: 'dekont-1', status: DekontStatus.rejected),
        ],
      );

      expect(merged.single.status, DueTransactionStatus.rejected);
    });
  });
}
