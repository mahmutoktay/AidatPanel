import 'package:aidatpanel/features/dashboard/presentation/utils/manager_dashboard_mapper.dart';
import 'package:aidatpanel/features/dues/domain/entities/due_entity.dart';
import 'package:flutter_test/flutter_test.dart';

DueEntity _due({
  required String id,
  required int month,
  required int year,
  DueStatus status = DueStatus.pending,
}) {
  return DueEntity(
    id: id,
    apartmentId: 'apt-$id',
    apartmentNumber: id,
    amount: 1000,
    currency: 'TRY',
    month: month,
    year: year,
    status: status,
    createdAt: DateTime(2026, month, 1),
    updatedAt: DateTime(2026, month, 1),
  );
}

void main() {
  group('ManagerDashboardMapper.filterDuesForMonth', () {
    test('10 daire x 6 ay PENDING → Haziran filtresi 10 kayıt', () {
      final dues = <DueEntity>[];
      for (var apt = 1; apt <= 10; apt++) {
        for (var month = 6; month <= 12; month++) {
          dues.add(
            _due(
              id: '$apt-$month',
              month: month,
              year: 2026,
              status: DueStatus.pending,
            ),
          );
        }
      }

      expect(dues.length, 70);
      expect(
        dues.where((d) => d.status == DueStatus.pending).length,
        70,
      );

      final juneDues = ManagerDashboardMapper.filterDuesForMonth(
        dues,
        month: 6,
        year: 2026,
      );

      expect(juneDues.length, 10);

      final stats = ManagerDashboardMapper.duesCollectionStats(juneDues);
      expect(stats.pendingCount, 10);
      expect(stats.paidCount, 0);
      expect(stats.overdueCount, 0);
    });

    test('tüm kayıtlar üzerinde 60 PENDING, bu ayda 10', () {
      final dues = List<DueEntity>.generate(
        60,
        (i) => _due(
          id: 'due-$i',
          month: 6 + (i ~/ 10),
          year: 2026,
        ),
      );

      final allStats = ManagerDashboardMapper.duesCollectionStats(dues);
      expect(allStats.pendingCount, 60);

      final currentMonth = ManagerDashboardMapper.filterDuesForMonth(
        dues,
        month: 6,
        year: 2026,
      );
      final monthStats =
          ManagerDashboardMapper.duesCollectionStats(currentMonth);
      expect(monthStats.pendingCount, 10);
    });
  });
}
