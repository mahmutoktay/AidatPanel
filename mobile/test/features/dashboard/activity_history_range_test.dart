import 'package:aidatpanel/features/dashboard/domain/activity_history_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 7, 8, 15, 30);

  group('ActivityHistoryRange.startAt', () {
    test('today starts at midnight', () {
      expect(
        ActivityHistoryRange.today.startAt(now),
        DateTime(2026, 7, 8),
      );
    });

    test('thisWeek starts on Monday', () {
      // 2026-07-08 is Wednesday
      expect(
        ActivityHistoryRange.thisWeek.startAt(now),
        DateTime(2026, 7, 6),
      );
    });

    test('thisMonth starts on first day', () {
      expect(
        ActivityHistoryRange.thisMonth.startAt(now),
        DateTime(2026, 7, 1),
      );
    });

    test('threeMonths handles year boundary', () {
      expect(
        ActivityHistoryRange.threeMonths.startAt(now),
        DateTime(2026, 4, 8),
      );
    });
  });

  group('isWithinActivityHistoryRange', () {
    test('includes item from today', () {
      expect(
        isWithinActivityHistoryRange(
          DateTime(2026, 7, 8, 9),
          ActivityHistoryRange.today,
          now: now,
        ),
        isTrue,
      );
    });

    test('excludes item before range', () {
      expect(
        isWithinActivityHistoryRange(
          DateTime(2026, 6, 1),
          ActivityHistoryRange.thisMonth,
          now: now,
        ),
        isFalse,
      );
    });
  });
}
