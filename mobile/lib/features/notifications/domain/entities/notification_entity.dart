import 'package:equatable/equatable.dart';

enum NotificationType {
  dueReminder,
  duePaid,
  ticketCreated,
  ticketUpdate,
  announcement,
  dekontReceived,
  dekontNeedsReview,
  dekontMatched,
  dekontPaymentApplied,
  expenseAdded,
  system,
  other,
}

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? code;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.code,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  bool get isFromAidatPanelTeam =>
      code == 'subscription_granted_admin' ||
      data?['source']?.toString() == 'admin_broadcast';

  @override
  List<Object?> get props =>
      [id, userId, title, body, type, code, isRead, data, createdAt];
}

class NotificationListResult {
  final List<NotificationEntity> items;
  final String? nextCursor;
  final int unreadCount;

  const NotificationListResult({
    required this.items,
    this.nextCursor,
    required this.unreadCount,
  });
}

class AnnouncementResultEntity extends Equatable {
  final int created;
  final int pushSent;
  final int pushFailed;
  final int pushSkipped;

  const AnnouncementResultEntity({
    required this.created,
    required this.pushSent,
    required this.pushFailed,
    this.pushSkipped = 0,
  });

  @override
  List<Object?> get props => [created, pushSent, pushFailed, pushSkipped];
}
