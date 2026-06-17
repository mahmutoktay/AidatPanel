import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/user_error_message.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationDataSource>((ref) {
  return NotificationRemoteDataSource(
    dioClient: ref.watch(dioClientProvider),
  );
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remote: ref.watch(notificationRemoteDataSourceProvider),
  );
});

/// Geriye uyumluluk — dev mock override.
@Deprecated('Use notificationRemoteDataSourceProvider')
final notificationDataSourceProvider = notificationRemoteDataSourceProvider;

class NotificationsState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<NotificationEntity> items;
  final int unreadCount;
  final String? nextCursor;
  final String? error;

  const NotificationsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.items = const [],
    this.unreadCount = 0,
    this.nextCursor,
    this.error,
  });

  bool get canLoadMore =>
      nextCursor != null && nextCursor!.isNotEmpty && !isLoading && !isLoadingMore;

  NotificationsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<NotificationEntity>? items,
    int? unreadCount,
    String? nextCursor,
    String? error,
    bool clearError = false,
    bool clearNextCursor = false,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  NotificationRepository get _repository =>
      ref.read(notificationRepositoryProvider);

  Timer? _badgeSyncDebounce;

  final Set<String> _toastedNotificationIds = {};
  bool _toastBaselineReady = false;
  bool _pollInFlight = false;
  int _lastPolledUnreadCount = 0;
  String? _lastPolledTopId;
  DateTime? _lastBadgeSyncAt;

  /// Rozet için minimum istek aralığı (sekme değişimi / prefetch).
  static const _badgeSyncMinInterval = Duration(seconds: 45);

  /// Arka plan poll — FCM yokken yedek; seyrek tutulur.
  static const _pollMinInterval = Duration(seconds: 90);
  static const _pollMinIntervalWhenUnread = Duration(seconds: 50);
  DateTime? _lastPollAt;

  @override
  NotificationsState build() {
    ref.onDispose(() {
      _badgeSyncDebounce?.cancel();
    });
    return const NotificationsState();
  }

  /// Oturum kapanınca / kullanıcı değişince toast tekrarını sıfırlar.
  void resetToastTracking() {
    _toastedNotificationIds.clear();
    _toastBaselineReady = false;
    _lastPolledUnreadCount = 0;
    _lastPolledTopId = null;
    _lastBadgeSyncAt = null;
    _lastPollAt = null;
  }

  bool isNotificationToasted(String id) => _toastedNotificationIds.contains(id);

  void markNotificationToasted(String id) {
    if (id.isEmpty) return;
    _toastBaselineReady = true;
    _toastedNotificationIds.add(id);
  }

  bool _shouldThrottleBadgeSync({required bool force}) {
    if (force) return false;
    final last = _lastBadgeSyncAt;
    if (last == null) return false;
    return DateTime.now().difference(last) < _badgeSyncMinInterval;
  }

  bool _shouldThrottlePoll({required bool force}) {
    if (force) return false;
    final last = _lastPollAt;
    if (last == null) return false;
    final minInterval = state.unreadCount > 0
        ? _pollMinIntervalWhenUnread
        : _pollMinInterval;
    return DateTime.now().difference(last) < minInterval;
  }

  /// Rozeti API ile senkronize eder (`GET /notifications/unread-count`).
  Future<void> syncUnreadBadge({bool force = false}) async {
    if (_shouldThrottleBadgeSync(force: force)) return;
    _lastBadgeSyncAt = DateTime.now();
    try {
      final count = await _repository.fetchUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (_) {
      // Ağ hatasında mevcut (optimistic) sayı korunur.
    }
  }

  /// Rozet + yeni toast: önce hafif sayaç, gerekirse okunmamış liste.
  Future<List<NotificationEntity>> pollForNewNotifications({bool force = false}) async {
    if (_pollInFlight) return const [];
    if (_shouldThrottlePoll(force: force)) return const [];
    _pollInFlight = true;
    _lastPollAt = DateTime.now();
    try {
      final unreadCount = await _repository.fetchUnreadCount();
      state = state.copyWith(unreadCount: unreadCount);

      if (!_toastBaselineReady) {
        await _establishToastBaseline(unreadCount);
        return const [];
      }

      final countIncreased = unreadCount > _lastPolledUnreadCount;
      _lastPolledUnreadCount = unreadCount;

      if (!countIncreased) {
        return const [];
      }

      final unread = await _repository.list(limit: 5, unreadOnly: true);
      state = state.copyWith(unreadCount: unread.unreadCount);
      _lastPolledUnreadCount = unread.unreadCount;
      if (unread.items.isNotEmpty) {
        final topId = unread.items.first.id;
        if (topId == _lastPolledTopId) {
          return const [];
        }
        _lastPolledTopId = topId;
      }
      return _extractNewForToast(unread.items);
    } catch (_) {
      return const [];
    } finally {
      _pollInFlight = false;
    }
  }

  Future<void> _establishToastBaseline(int unreadCount) async {
    _toastBaselineReady = true;
    _lastPolledUnreadCount = unreadCount;
    if (unreadCount > 0) {
      final unread = await _repository.list(limit: 10, unreadOnly: true);
      _toastedNotificationIds.addAll(unread.items.map((n) => n.id));
      if (unread.items.isNotEmpty) {
        _lastPolledTopId = unread.items.first.id;
      }
      state = state.copyWith(unreadCount: unread.unreadCount);
      _lastPolledUnreadCount = unread.unreadCount;
    }
  }

  List<NotificationEntity> _extractNewForToast(List<NotificationEntity> items) {
    if (!_toastBaselineReady) {
      _toastedNotificationIds.addAll(items.map((n) => n.id));
      _toastBaselineReady = true;
      return const [];
    }

    final fresh = <NotificationEntity>[];
    for (final n in items) {
      if (_toastedNotificationIds.contains(n.id)) continue;
      _toastedNotificationIds.add(n.id);
      fresh.add(n);
    }
    return fresh.reversed.toList();
  }

  /// FCM push geldiğinde: optimistic +1, ardından hafif rozet senkronu.
  void onPushReceived() {
    state = state.copyWith(unreadCount: state.unreadCount + 1);

    _badgeSyncDebounce?.cancel();
    _badgeSyncDebounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(syncUnreadBadge(force: true));
    });
  }

  Future<void> load({bool refresh = true}) async {
    if (!refresh && !state.canLoadMore) return;

    state = state.copyWith(
      isLoading: refresh,
      isLoadingMore: !refresh,
      clearError: true,
      clearNextCursor: refresh,
    );
    try {
      final result = await _repository.list(
        cursor: refresh ? null : state.nextCursor,
      );
      final merged = refresh
          ? result.items
          : [...state.items, ...result.items];
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        items: merged,
        unreadCount: result.unreadCount,
        nextCursor: result.nextCursor,
        clearNextCursor: result.nextCursor == null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: userFacingError(e),
      );
    }
  }

  Future<void> loadMore() => load(refresh: false);

  Future<void> markRead(String id) async {
    await _repository.markRead(id);
    final items = [
      for (final n in state.items)
        if (n.id == id)
          NotificationEntity(
            id: n.id,
            userId: n.userId,
            title: n.title,
            body: n.body,
            type: n.type,
            isRead: true,
            data: n.data,
            createdAt: n.createdAt,
          )
        else
          n,
    ];
    state = state.copyWith(
      items: items,
      unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
    );
  }

  Future<void> markAllRead() async {
    await _repository.markAllRead();
    final items = [
      for (final n in state.items)
        NotificationEntity(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          type: n.type,
          isRead: true,
          data: n.data,
          createdAt: n.createdAt,
        ),
    ];
    state = state.copyWith(items: items, unreadCount: 0);
  }

  Future<AnnouncementResultEntity?> sendAnnouncement(
    String buildingId, {
    required String title,
    required String body,
  }) async {
    try {
      return await _repository.sendAnnouncement(
        buildingId,
        title: title,
        body: body,
      );
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return null;
    }
  }
}

final notificationsNotifierProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
