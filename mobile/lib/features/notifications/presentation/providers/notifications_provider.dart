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

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationRepository _repository;
  Timer? _badgeSyncDebounce;

  final Set<String> _toastedNotificationIds = {};
  bool _toastBaselineReady = false;
  bool _pollInFlight = false;

  NotificationsNotifier(this._repository) : super(const NotificationsState());

  @override
  void dispose() {
    _badgeSyncDebounce?.cancel();
    super.dispose();
  }

  /// Oturum kapanınca / kullanıcı değişince toast tekrarını sıfırlar.
  void resetToastTracking() {
    _toastedNotificationIds.clear();
    _toastBaselineReady = false;
  }

  void markNotificationToasted(String id) {
    if (id.isEmpty) return;
    _toastBaselineReady = true;
    _toastedNotificationIds.add(id);
  }

  /// Rozeti API ile senkronize eder (liste ekranını etkilemez).
  Future<void> syncUnreadBadge() async {
    try {
      final result = await _repository.list(limit: 1);
      state = state.copyWith(unreadCount: result.unreadCount);
    } catch (_) {
      // Ağ hatasında mevcut (optimistic) sayı korunur.
    }
  }

  /// Okunmamışları kontrol eder; daha önce gösterilmemiş olanları döner (toast için).
  Future<List<NotificationEntity>> pollForNewNotifications() async {
    if (_pollInFlight) return const [];
    _pollInFlight = true;
    try {
      final result = await _repository.list(limit: 10, unreadOnly: true);
      state = state.copyWith(unreadCount: result.unreadCount);
      return _extractNewForToast(result.items);
    } catch (_) {
      return const [];
    } finally {
      _pollInFlight = false;
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
    // API en yeni önce — kuyruk eskiden yeniye işlesin.
    return fresh.reversed.toList();
  }

  /// FCM push geldiğinde: önce anında +1, ardından sunucudan doğrula.
  void onPushReceived() {
    state = state.copyWith(unreadCount: state.unreadCount + 1);

    _badgeSyncDebounce?.cancel();
    _badgeSyncDebounce = Timer(const Duration(milliseconds: 200), () {
      unawaited(syncUnreadBadge());
    });

    unawaited(load(refresh: true));
  }

  Future<void> load({bool refresh = true}) async {
    if (!refresh && !state.canLoadMore) return;

    state = state.copyWith(
      isLoading: refresh,
      isLoadingMore: !refresh,
      clearError: true,
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
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.watch(notificationRepositoryProvider));
});
