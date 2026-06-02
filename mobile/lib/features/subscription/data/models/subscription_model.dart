import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel {
  final String? id;
  final String status;
  final String plan;
  final DateTime? currentPeriodEnd;

  const SubscriptionModel({
    this.id,
    required this.status,
    required this.plan,
    this.currentPeriodEnd,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    DateTime? end;
    final endRaw = json['currentPeriodEnd'] ?? json['expiresAt'];
    if (endRaw is String && endRaw.isNotEmpty) {
      end = DateTime.tryParse(endRaw);
    }

    return SubscriptionModel(
      id: json['id'] as String?,
      status: (json['status'] as String? ?? '').toUpperCase(),
      plan: json['plan'] as String? ?? '',
      currentPeriodEnd: end,
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
    );
  }
}
