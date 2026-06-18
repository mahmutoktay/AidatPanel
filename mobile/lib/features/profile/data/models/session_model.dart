import '../../domain/entities/session_entity.dart';

class SessionModel {
  final String id;
  final String deviceLabel;
  final String platform;
  final DateTime createdAt;
  final DateTime lastSeenAt;
  final bool isCurrent;

  SessionModel({
    required this.id,
    required this.deviceLabel,
    required this.platform,
    required this.createdAt,
    required this.lastSeenAt,
    required this.isCurrent,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      deviceLabel: json['deviceLabel'] as String? ?? 'Bilinmeyen cihaz',
      platform: json['platform'] as String? ?? 'unknown',
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  SessionEntity toEntity() => SessionEntity(
        id: id,
        deviceLabel: deviceLabel,
        platform: platform,
        createdAt: createdAt,
        lastSeenAt: lastSeenAt,
        isCurrent: isCurrent,
      );
}
