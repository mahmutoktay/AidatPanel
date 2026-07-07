import 'package:aidatpanel/features/dashboard/domain/resident_home_activity_item.dart';
import 'package:aidatpanel/features/dues/domain/entities/due_entity.dart';
import 'package:aidatpanel/features/dues/domain/entities/due_transaction_entity.dart';
import 'package:aidatpanel/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildResidentHomeActivityFeed merges and sorts by date desc', () {
    final feed = buildResidentHomeActivityFeed(
      transactions: [
        DueTransactionEntity(
          id: 'payment-1',
          kind: DueTransactionKind.payment,
          source: DueTransactionSource.manual,
          amount: 500,
          currency: 'TRY',
          occurredAt: DateTime(2026, 7, 1),
          status: DueTransactionStatus.approved,
          dueId: 'due-1',
        ),
      ],
      announcements: [
        NotificationEntity(
          id: 'n1',
          userId: 'u1',
          title: 'Duyuru',
          body: 'Asansör bakımı yapılacak',
          type: NotificationType.announcement,
          isRead: false,
          createdAt: DateTime(2026, 7, 7, 22, 8),
        ),
      ],
    );

    expect(feed, hasLength(2));
    expect(feed.first.isAnnouncement, isTrue);
    expect(feed.last.isTransaction, isTrue);
  });

  test('duesByIdMap indexes dues by id', () {
    final due = DueEntity(
      id: 'due-1',
      apartmentId: 'a1',
      apartmentNumber: '1A',
      amount: 500,
      currency: 'TRY',
      month: 7,
      year: 2026,
      status: DueStatus.paid,
      paidAt: DateTime(2026, 7, 1),
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );
    final map = duesByIdMap([due]);
    expect(map['due-1']?.month, 7);
  });
}
