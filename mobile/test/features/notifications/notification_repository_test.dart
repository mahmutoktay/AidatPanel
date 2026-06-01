import 'package:aidatpanel/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:aidatpanel/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:aidatpanel/features/notifications/domain/entities/notification_entity.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  group('NotificationRepositoryImpl.countAnnouncementsInMonth', () {
    test('bu ayki duyuruları sayar', () async {
      final now = DateTime.now();
      final repo = NotificationRepositoryImpl(remote: _FakeNotificationDs(now));

      final count = await repo.countAnnouncementsInMonth(reference: now);

      expect(count, 2);
    });
  });
}

class _FakeNotificationDs implements NotificationDataSource {
  _FakeNotificationDs(this._now);

  final DateTime _now;

  @override
  Future<int> fetchUnreadCount() async => 2;

  @override
  Future<NotificationListResult> list({
    bool unreadOnly = false,
    int limit = 20,
    String? cursor,
  }) async {
    final items = [
      NotificationEntity(
        id: 'a1',
        userId: 'u1',
        title: 'Duyuru 1',
        body: 'b',
        type: NotificationType.announcement,
        isRead: false,
        createdAt: DateTime(_now.year, _now.month, 5),
      ),
      NotificationEntity(
        id: 'a2',
        userId: 'u1',
        title: 'Duyuru 2',
        body: 'b',
        type: NotificationType.announcement,
        isRead: true,
        createdAt: DateTime(_now.year, _now.month, 10),
      ),
      NotificationEntity(
        id: 'old',
        userId: 'u1',
        title: 'Eski duyuru',
        body: 'b',
        type: NotificationType.announcement,
        isRead: false,
        createdAt: _now.subtract(const Duration(days: 45)),
      ),
      NotificationEntity(
        id: 't1',
        userId: 'u1',
        title: 'Talep',
        body: 'b',
        type: NotificationType.ticketCreated,
        isRead: false,
        createdAt: DateTime(_now.year, _now.month, 12),
      ),
    ];
    return NotificationListResult(
      items: items,
      unreadCount: 2,
    );
  }

  @override
  Future<NotificationEntity> markRead(String id) =>
      throw UnimplementedError();

  @override
  Future<int> markAllRead() => throw UnimplementedError();

  @override
  Future<AnnouncementResultEntity> sendAnnouncement(
    String buildingId, {
    required String title,
    required String body,
  }) =>
      throw UnimplementedError();
}
