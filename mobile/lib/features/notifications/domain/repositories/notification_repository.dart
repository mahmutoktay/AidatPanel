import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<NotificationListResult> list({
    bool unreadOnly = false,
    int limit = 20,
    String? cursor,
  });

  Future<int> countAnnouncementsInMonth({
    int limit = 100,
    DateTime? reference,
  });

  Future<NotificationEntity> markRead(String id);

  Future<int> markAllRead();

  Future<AnnouncementResultEntity> sendAnnouncement(
    String buildingId, {
    required String title,
    required String body,
  });
}
