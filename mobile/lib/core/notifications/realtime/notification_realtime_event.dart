import '../notification_payload.dart';

/// Sunucudan veya FCM/poll kanalından gelen tek tip olay (Instagram-benzeri genişleme).
enum NotificationRealtimeChannel {
  fcm,
  polling,
  webSocket,
}

class NotificationRealtimeEvent {
  final NotificationRealtimeChannel channel;
  final NotificationPayload payload;
  final String? title;
  final String? body;

  /// Tray/toast göster (FCM ön planda zaten tray üretir).
  final bool showToast;

  /// Rozeti sunucudan doğrula.
  final bool syncBadge;

  const NotificationRealtimeEvent({
    required this.channel,
    required this.payload,
    this.title,
    this.body,
    this.showToast = true,
    this.syncBadge = true,
  });

  factory NotificationRealtimeEvent.fromFcmData(Map<String, dynamic> data) {
    return NotificationRealtimeEvent(
      channel: NotificationRealtimeChannel.fcm,
      payload: NotificationPayload.fromFcmData(data),
      title: data['title']?.toString(),
      body: data['body']?.toString(),
      showToast: true,
      syncBadge: true,
    );
  }

  /// Backend `notification.created` WebSocket gövdesi ile aynı sözleşme.
  factory NotificationRealtimeEvent.fromRealtimeJson(
    Map<String, dynamic> json,
  ) {
    final data = <String, dynamic>{
      'type': json['type']?.toString() ?? json['event']?.toString(),
      'notificationId': json['notificationId']?.toString(),
      'title': json['title']?.toString(),
      'body': json['body']?.toString(),
      if (json['data'] is Map)
        ...Map<String, dynamic>.from(json['data'] as Map),
    };
    return NotificationRealtimeEvent(
      channel: NotificationRealtimeChannel.webSocket,
      payload: NotificationPayload.fromFcmData(data),
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      showToast: true,
      syncBadge: true,
    );
  }
}
