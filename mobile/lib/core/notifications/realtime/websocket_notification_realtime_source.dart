import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../constants/api_constants.dart';
import '../../storage/secure_storage.dart';
import '../constants/realtime_events.dart';
import 'notification_realtime_event.dart';
import 'notification_realtime_source.dart';

/// WebSocket — uygulama açıkken anında `notification.created`.
class WebSocketNotificationRealtimeSource implements NotificationRealtimeSource {
  WebSocketNotificationRealtimeSource({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  final SecureStorage _secureStorage;

  NotificationRealtimeCallback? _onEvent;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _wantConnected = false;
  int _reconnectAttempt = 0;

  static const _maxReconnectDelay = Duration(seconds: 60);

  @override
  String get name => 'websocket';

  @override
  Future<void> start(NotificationRealtimeCallback onEvent) async {
    _onEvent = onEvent;
    _wantConnected = true;
    await _connect();
  }

  @override
  Future<void> stop() async {
    _wantConnected = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  @override
  Future<void> onAuthenticated({bool force = false}) async {
    await _reconnect();
  }

  @override
  Future<void> onForegroundResumed() async {
    await _reconnect();
  }

  Future<void> _reconnect() async {
    await stop();
    _wantConnected = true;
    _reconnectAttempt = 0;
    await _connect();
  }

  Future<void> _connect() async {
    if (!_wantConnected || _onEvent == null) return;

    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        debugPrint('[realtime] WebSocket: JWT yok, bağlantı atlandı.');
      }
      return;
    }

    final uri = ApiConstants.realtimeWebSocketUri(token);
    try {
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;
      _subscription = channel.stream.listen(
        _onMessage,
        onError: _onConnectionLost,
        onDone: _onConnectionLost,
        cancelOnError: true,
      );
      _reconnectAttempt = 0;
      if (kDebugMode) {
        debugPrint('[realtime] WebSocket bağlandı: $uri');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[realtime] WebSocket bağlantı hatası: $e');
      }
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    if (raw is! String) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final event = json['event']?.toString();
      if (event == RealtimeEvents.connected) return;
      if (event == RealtimeEvents.notificationCreated || event == 'force_logout') {
        _onEvent?.call(NotificationRealtimeEvent.fromRealtimeJson(json));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[realtime] WebSocket mesaj parse hatası: $e');
      }
    }
  }

  void _onConnectionLost([Object? _]) {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_wantConnected) return;
    _reconnectTimer?.cancel();
    _reconnectAttempt += 1;
    final seconds =
        (_reconnectAttempt * 3).clamp(3, _maxReconnectDelay.inSeconds);
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      unawaited(_connect());
    });
  }
}
