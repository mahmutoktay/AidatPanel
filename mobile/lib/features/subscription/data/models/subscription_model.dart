import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel {
  final String? id;
  final String status;
  final String plan;
  final DateTime? currentPeriodEnd;
  final int? managementUnitsUsed;
  final int? managementUnitsLimit;

  const SubscriptionModel({
    this.id,
    required this.status,
    required this.plan,
    this.currentPeriodEnd,
    this.managementUnitsUsed,
    this.managementUnitsLimit,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    DateTime? end;
    final endRaw = json['currentPeriodEnd'] ?? json['expiresAt'];
    if (endRaw is String && endRaw.isNotEmpty) {
      end = DateTime.tryParse(endRaw);
    }

    int? used;
    int? limit;
    final usage = json['usage'];
    final limits = json['limits'];
    if (usage is Map<String, dynamic>) {
      used = (usage['managementUnits'] as num?)?.toInt();
    }
    if (limits is Map<String, dynamic>) {
      limit = (limits['managementUnits'] as num?)?.toInt();
    }

    return SubscriptionModel(
      id: json['id'] as String?,
      status: (json['status'] as String? ?? '').toUpperCase(),
      plan: json['plan'] as String? ?? '',
      currentPeriodEnd: end,
      managementUnitsUsed: used,
      managementUnitsLimit: limit,
    );
  }

  SubscriptionEntity toEntity() {
    SubscriptionStatus mapped;
    switch (status) {
      case 'ACTIVE':
        mapped = SubscriptionStatus.active;
        break;
      case 'EXPIRED':
        mapped = SubscriptionStatus.expired;
        break;
      case 'CANCELLED':
        mapped = SubscriptionStatus.cancelled;
        break;
      case 'TRIAL':
        mapped = SubscriptionStatus.trial;
        break;
      default:
        mapped = SubscriptionStatus.unknown;
    }

    return SubscriptionEntity(
      id: id,
      status: mapped,
      plan: plan,
      currentPeriodEnd: currentPeriodEnd,
      managementUnitsUsed: managementUnitsUsed,
      managementUnitsLimit: managementUnitsLimit,
    );
  }
}
