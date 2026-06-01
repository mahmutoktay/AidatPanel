import 'entities/due_entity.dart';

/// year*12 + month — kronolojik sıralama anahtarı
int duePeriodKey(int year, int month) => year * 12 + month;

/// Dönem (ay/yıl) cihazın güncel ayına eşit veya daha eski mi?
bool isDuePeriodAtOrBeforeNow(int month, int year, DateTime now) {
  final current = duePeriodKey(now.year, now.month);
  return duePeriodKey(year, month) <= current;
}

/// Sakin listesi: güncel ay dahil geçmiş dönemler; gelecek dönemler hariç;
/// güncelden eskiye sıralı.
List<DueEntity> prepareResidentDuesList(
  List<DueEntity> dues, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final filtered = dues
      .where((d) => isDuePeriodAtOrBeforeNow(d.month, d.year, clock))
      .toList();
  filtered.sort((a, b) {
    final cmp = duePeriodKey(b.year, b.month)
        .compareTo(duePeriodKey(a.year, a.month));
    if (cmp != 0) return cmp;
    return b.updatedAt.compareTo(a.updatedAt);
  });
  return filtered;
}

/// Cihazın güncel takvim ayı/yılı ile aynı dönem mi?
bool isCurrentPeriodDue(DueEntity due, DateTime now) =>
    due.year == now.year && due.month == now.month;

/// Görüntüleme: güncel dönem(ler) ve geçmiş; sıra korunur.
({List<DueEntity> current, List<DueEntity> past}) splitResidentDuesForDisplay(
  List<DueEntity> dues, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final current = <DueEntity>[];
  final past = <DueEntity>[];
  for (final due in dues) {
    if (isCurrentPeriodDue(due, clock)) {
      current.add(due);
    } else {
      past.add(due);
    }
  }
  return (current: current, past: past);
}
