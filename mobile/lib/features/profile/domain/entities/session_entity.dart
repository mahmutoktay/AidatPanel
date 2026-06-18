import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  final String id;
  final String deviceLabel;
  final String platform;
  final DateTime createdAt;
  final DateTime lastSeenAt;
  final bool isCurrent;

  const SessionEntity({
    required this.id,
    required this.deviceLabel,
    required this.platform,
    required this.createdAt,
    required this.lastSeenAt,
    required this.isCurrent,
  });

  @override
  List<Object?> get props => [
        id,
        deviceLabel,
        platform,
        createdAt,
        lastSeenAt,
        isCurrent,
      ];
}
