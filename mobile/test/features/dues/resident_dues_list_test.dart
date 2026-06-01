import 'package:aidatpanel/features/dues/domain/entities/due_entity.dart';
import 'package:aidatpanel/features/dues/domain/resident_dues_list.dart';
import 'package:flutter_test/flutter_test.dart';

DueEntity _due({
  required String id,
  required int month,
  required int year,
  DateTime? updatedAt,
}) {
  final ts = updatedAt ?? DateTime(2026, month, 1);
  return DueEntity(
    id: id,
    apartmentId: 'apt-1',
    apartmentNumber: '1',
    amount: 500,
    currency: 'TRY',
    month: month,
    year: year,
    status: DueStatus.pending,
    createdAt: ts,
    updatedAt: ts,
  );
}

void main() {
  group('isDuePeriodAtOrBeforeNow', () {
    final now = DateTime(2026, 7, 15);

    test('güncel ay dahil', () {
      expect(isDuePeriodAtOrBeforeNow(7, 2026, now), isTrue);
    });

    test('geçmiş ay dahil', () {
      expect(isDuePeriodAtOrBeforeNow(6, 2026, now), isTrue);
    });

    test('gelecek ay hariç', () {
      expect(isDuePeriodAtOrBeforeNow(8, 2026, now), isFalse);
    });

    test('gelecek yıl hariç', () {
      expect(isDuePeriodAtOrBeforeNow(1, 2027, now), isFalse);
    });
  });

  group('prepareResidentDuesList', () {
    final now = DateTime(2026, 7, 15);

    test('gelecek dönemleri çıkarır', () {
      final input = [
        _due(id: 'july', month: 7, year: 2026),
        _due(id: 'aug', month: 8, year: 2026),
        _due(id: 'next-year', month: 1, year: 2027),
        _due(id: 'june', month: 6, year: 2026),
      ];

      final result = prepareResidentDuesList(input, now: now);

      expect(result.map((d) => d.id).toList(), ['july', 'june']);
    });

    test('güncelden eskiye sıralar', () {
      final input = [
        _due(id: 'may', month: 5, year: 2026),
        _due(id: 'july', month: 7, year: 2026),
        _due(id: 'june', month: 6, year: 2026),
        _due(id: 'dec-2025', month: 12, year: 2025),
      ];

      final result = prepareResidentDuesList(input, now: now);

      expect(
        result.map((d) => '${d.month}/${d.year}').toList(),
        ['7/2026', '6/2026', '5/2026', '12/2025'],
      );
    });

    test('splitResidentDuesForDisplay güncel ve geçmiş ayırır', () {
      final input = [
        _due(id: 'july', month: 7, year: 2026),
        _due(id: 'june', month: 6, year: 2026),
        _due(id: 'may', month: 5, year: 2026),
      ];
      final now = DateTime(2026, 7, 15);

      final split = splitResidentDuesForDisplay(input, now: now);

      expect(split.current.map((d) => d.id).toList(), ['july']);
      expect(split.past.map((d) => d.id).toList(), ['june', 'may']);
    });

    test('aynı dönemde updatedAt yeniden eskiye', () {
      final input = [
        _due(
          id: 'older',
          month: 6,
          year: 2026,
          updatedAt: DateTime(2026, 6, 1),
        ),
        _due(
          id: 'newer',
          month: 6,
          year: 2026,
          updatedAt: DateTime(2026, 6, 20),
        ),
      ];

      final result = prepareResidentDuesList(input, now: now);

      expect(result.map((d) => d.id).toList(), ['newer', 'older']);
    });
  });
}
