import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel {
  final String? id;
  final String status;
  final String plan;
  final DateTime? currentPeriodEnd;
  final int? usageBuildings;
  final int? limitBuildings;

  const SubscriptionModel({
    this.id,
    required this.status,
    required this.plan,
    this.currentPeriodEnd,
    this.usageBuildings,
    this.limitBuildings,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    DateTime? end;
    final endRaw = json['currentPeriodEnd'] ?? json['expiresAt'];
    if (endRaw is String && endRaw.isNotEmpty) {
      end = DateTime.tryParse(endRaw);
    }

    int? usageBuildings;
    int? limitBuildings;
    final usage = json['usage'];
    if (usage is Map<String, dynamic>) {
      usageBuildings = usage['buildings'] as int?;
    }
    final limits = json['limits'];
    if (limits is Map<String, dynamic>) {
      final raw = limits['buildings'];
      limitBuildings = raw is int ? raw : null;
    }

    return SubscriptionModel(
      id: json['id'] as String?,
      status: (json['status'] as String? ?? '').toUpperCase(),
      plan: json['plan'] as String? ?? '',
      currentPeriodEnd: end,
      usageBuildings: usageBuildings,
      limitBuildings: limitBuildings,
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
      usage: usageBuildings != null
          ? SubscriptionUsageEntity(buildings: usageBuildings!)
          : null,
      limits: SubscriptionLimitsEntity(buildings: limitBuildings),
    );
  }
}
