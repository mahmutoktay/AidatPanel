import '../../../../core/network/api_exception.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource _remote;

  NotificationRepositoryImpl({required NotificationDataSource remote})
      : _remote = remote;

  @override
  Future<int> fetchUnreadCount() async {
    try {
      return await _remote.fetchUnreadCount();
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        final snapshot = await list(limit: 1);
        return snapshot.unreadCount;
      }
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Bildirim sayısı alınırken bir hata oluştu');
    }
  }

  @override
  Future<NotificationListResult> list({
    bool unreadOnly = false,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      return await _remote.list(
        unreadOnly: unreadOnly,
        limit: limit,
        cursor: cursor,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Bildirimler alınırken bir hata oluştu');
    }
  }

  @override
  Future<int> countAnnouncementsInMonth({
    int limit = 100,
    DateTime? reference,
  }) async {
    final now = reference ?? DateTime.now();
    try {
      final result = await _remote.list(limit: limit);
      return result.items
          .where(
            (n) =>
                n.type == NotificationType.announcement &&
                n.createdAt.year == now.year &&
                n.createdAt.month == now.month,
          )
          .length;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Duyuru sayısı alınırken bir hata oluştu');
    }
  }

  @override
  Future<NotificationEntity> markRead(String id) async {
    try {
      return await _remote.markRead(id);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Bildirim okunurken bir hata oluştu');
    }
  }

  @override
  Future<int> markAllRead() async {
    try {
      return await _remote.markAllRead();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Bildirimler okunurken bir hata oluştu');
    }
  }

  @override
  Future<AnnouncementResultEntity> sendAnnouncement(
    String buildingId, {
    required String title,
    required String body,
  }) async {
    try {
      return await _remote.sendAnnouncement(
        buildingId,
        title: title,
        body: body,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Duyuru gönderilirken bir hata oluştu');
    }
  }
}
