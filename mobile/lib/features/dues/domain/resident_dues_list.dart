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

/// Hesap özeti: ödenmiş/muaf geçmiş + yalnızca güncel ayın açık aidatı.
/// Eski dönemlerdeki PENDING/OVERDUE kayıtları listelenmez.
bool shouldShowInAccountSummary(DueEntity due, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  if (!isDuePeriodAtOrBeforeNow(due.month, due.year, clock)) {
    return false;
  }
  if (due.status == DueStatus.paid || due.status == DueStatus.waived) {
    return true;
  }
  return isCurrentPeriodDue(due, clock);
}
