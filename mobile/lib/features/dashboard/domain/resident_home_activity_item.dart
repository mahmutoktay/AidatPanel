import '../../dues/domain/entities/due_entity.dart';
import '../../dues/domain/entities/due_transaction_entity.dart';
import '../../notifications/domain/entities/notification_entity.dart';

/// Sakin ana sayfa — ödeme hareketi veya duyuru satırı.
class ResidentHomeActivityItem {
  final DateTime occurredAt;
  final DueTransactionEntity? transaction;
  final NotificationEntity? announcement;

  const ResidentHomeActivityItem._({
    required this.occurredAt,
    this.transaction,
    this.announcement,
  });

  factory ResidentHomeActivityItem.transaction(DueTransactionEntity transaction) {
    return ResidentHomeActivityItem._(
      occurredAt: transaction.occurredAt,
      transaction: transaction,
    );
  }

  factory ResidentHomeActivityItem.announcement(
    NotificationEntity announcement,
  ) {
    return ResidentHomeActivityItem._(
      occurredAt: announcement.createdAt,
      announcement: announcement,
    );
  }

  bool get isTransaction => transaction != null;
  bool get isAnnouncement => announcement != null;
}

List<ResidentHomeActivityItem> buildResidentHomeActivityFeed({
  required List<DueTransactionEntity> transactions,
  required List<NotificationEntity> announcements,
}) {
  final items = <ResidentHomeActivityItem>[
    for (final transaction in transactions)
      ResidentHomeActivityItem.transaction(transaction),
    for (final announcement in announcements)
      ResidentHomeActivityItem.announcement(announcement),
  ];
  items.sort((a, b) {
    final diff = b.occurredAt.compareTo(a.occurredAt);
    if (diff != 0) return diff;
    return b.occurredAt.microsecond.compareTo(a.occurredAt.microsecond);
  });
  return items;
}

/// dueId → dönem bilgisi.
Map<String, DueEntity> duesByIdMap(List<DueEntity> dues) {
  return {for (final due in dues) due.id: due};
}
