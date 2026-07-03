import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel {
  final String? id;
  final String status;
  final String plan;
  final DateTime? currentPeriodEnd;
<<<<<<< HEAD
  final int? managementUnitsUsed;
  final int? managementUnitsLimit;
=======
  final int? usageBuildings;
  final int? limitBuildings;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

  const SubscriptionModel({
    this.id,
    required this.status,
    required this.plan,
    this.currentPeriodEnd,
<<<<<<< HEAD
    this.managementUnitsUsed,
    this.managementUnitsLimit,
=======
    this.usageBuildings,
    this.limitBuildings,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    DateTime? end;
    final endRaw = json['currentPeriodEnd'] ?? json['expiresAt'];
    if (endRaw is String && endRaw.isNotEmpty) {
      end = DateTime.tryParse(endRaw);
    }

<<<<<<< HEAD
    int? used;
    int? limit;
    final usage = json['usage'];
    final limits = json['limits'];
    if (usage is Map<String, dynamic>) {
      used = (usage['managementUnits'] as num?)?.toInt();
    }
    if (limits is Map<String, dynamic>) {
      limit = (limits['managementUnits'] as num?)?.toInt();
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }

    return SubscriptionModel(
      id: json['id'] as String?,
      status: (json['status'] as String? ?? '').toUpperCase(),
      plan: json['plan'] as String? ?? '',
      currentPeriodEnd: end,
<<<<<<< HEAD
      managementUnitsUsed: used,
      managementUnitsLimit: limit,
=======
      usageBuildings: usageBuildings,
      limitBuildings: limitBuildings,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
      managementUnitsUsed: managementUnitsUsed,
      managementUnitsLimit: managementUnitsLimit,
=======
      usage: usageBuildings != null
          ? SubscriptionUsageEntity(buildings: usageBuildings!)
          : null,
      limits: SubscriptionLimitsEntity(buildings: limitBuildings),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    );
  }
}
