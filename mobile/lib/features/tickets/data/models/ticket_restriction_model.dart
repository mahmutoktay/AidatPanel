import '../../domain/entities/ticket_restriction_entity.dart';
import 'ticket_model.dart';

class TicketRestrictionModel {
  final String reason;
  final DateTime expiresAt;
  final DateTime createdAt;

  const TicketRestrictionModel({
    required this.reason,
    required this.expiresAt,
    required this.createdAt,
  });

  factory TicketRestrictionModel.fromJson(Map<String, dynamic> json) {
    return TicketRestrictionModel(
      reason: (json['reason'] ?? '') as String,
      expiresAt: TicketModel.parseDate(json['expiresAt']),
      createdAt: TicketModel.parseDate(json['createdAt']),
    );
  }

  TicketRestrictionEntity toEntity() => TicketRestrictionEntity(
        reason: reason,
        expiresAt: expiresAt,
        createdAt: createdAt,
      );
}

class TicketRestrictionStatusModel {
  final bool active;
  final TicketRestrictionModel? restriction;

  const TicketRestrictionStatusModel({
    required this.active,
    this.restriction,
  });

  factory TicketRestrictionStatusModel.fromJson(Map<String, dynamic> json) {
    final raw = json['restriction'];
    return TicketRestrictionStatusModel(
      active: json['active'] == true,
      restriction: raw is Map<String, dynamic>
          ? TicketRestrictionModel.fromJson(raw)
          : null,
    );
  }

  TicketRestrictionStatusEntity toEntity() => TicketRestrictionStatusEntity(
        active: active,
        restriction: restriction?.toEntity(),
      );
}
