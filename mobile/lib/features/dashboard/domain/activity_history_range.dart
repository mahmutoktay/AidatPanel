/// Sakin hareket geçmişi zaman aralığı filtreleri.
enum ActivityHistoryRange {
  today,
  thisWeek,
  thisMonth,
  threeMonths,
  sixMonths,
}

extension ActivityHistoryRangeX on ActivityHistoryRange {
  /// `occurredAt >= start` (gün başı dahil).
  DateTime startAt(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case ActivityHistoryRange.today:
        return today;
      case ActivityHistoryRange.thisWeek:
        return today.subtract(Duration(days: now.weekday - DateTime.monday));
      case ActivityHistoryRange.thisMonth:
        return DateTime(now.year, now.month, 1);
      case ActivityHistoryRange.threeMonths:
        return _monthsBefore(now, 3);
      case ActivityHistoryRange.sixMonths:
        return _monthsBefore(now, 6);
    }
  }

  DateTime _monthsBefore(DateTime now, int months) {
    var month = now.month - months;
    var year = now.year;
    while (month < 1) {
      month += 12;
      year--;
    }
    final day = now.day;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDay ? lastDay : day);
  }
}

bool isWithinActivityHistoryRange(
  DateTime occurredAt,
  ActivityHistoryRange range, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final start = range.startAt(clock);
  return !occurredAt.isBefore(start) && !occurredAt.isAfter(clock);
}

List<T> filterByActivityHistoryRange<T>(
  Iterable<T> items,
  ActivityHistoryRange range,
  DateTime Function(T item) readOccurredAt, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final start = range.startAt(clock);
  return [
    for (final item in items)
      if (!readOccurredAt(item).isBefore(start) &&
          !readOccurredAt(item).isAfter(clock))
        item,
  ];
}
