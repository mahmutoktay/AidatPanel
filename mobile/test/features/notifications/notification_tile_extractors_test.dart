import 'package:flutter_test/flutter_test.dart';

import 'package:aidatpanel/features/notifications/domain/entities/notification_entity.dart';
import 'package:aidatpanel/features/notifications/presentation/utils/notification_tile_extractors.dart';

final _createdAt = DateTime(2026, 6, 17);

void main() {
  group('notificationTileApartmentLabel', () {
    test('prefers payload apartmentNumber over body text', () {
      final notification = NotificationEntity(
        id: '1',
        userId: 'u1',
        title: 'Aidat',
        body: 'Daire 5 — ödeme alındı',
        type: NotificationType.duePaid,
        isRead: false,
        createdAt: _createdAt,
        data: const {'apartmentNumber': 'Daire 12'},
      );

      expect(
        notificationTileApartmentLabel(notification),
        'Daire 12',
      );
    });

    test('falls back to body prefix when payload missing', () {
      final notification = NotificationEntity(
        id: '1',
        userId: 'u1',
        title: 'Talep',
        body: 'Daire 3 — yeni talep',
        type: NotificationType.ticketCreated,
        isRead: false,
        createdAt: _createdAt,
      );

      expect(notificationTileApartmentLabel(notification), 'Daire 3');
    });
  });

  group('notificationTileAmount', () {
    test('reads numeric amount from payload', () {
      final notification = NotificationEntity(
        id: '1',
        userId: 'u1',
        title: 'Gider',
        body: 'Başka metin',
        type: NotificationType.expenseAdded,
        isRead: false,
        createdAt: _createdAt,
        data: const {'amount': 850},
      );

      expect(notificationTileAmount(notification), '₺850');
    });

    test('falls back to body regex', () {
      final notification = NotificationEntity(
        id: '1',
        userId: 'u1',
        title: 'Aidat',
        body: 'Daire 2 için ₺1.200 ödendi',
        type: NotificationType.duePaid,
        isRead: false,
        createdAt: _createdAt,
      );

      expect(notificationTileAmount(notification), '₺1.200');
    });
  });
}
