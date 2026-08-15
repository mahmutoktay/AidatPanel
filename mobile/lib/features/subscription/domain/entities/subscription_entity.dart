import 'package:equatable/equatable.dart';

enum SubscriptionStatus { active, expired, cancelled, trial, unknown }

class SubscriptionUsageEntity extends Equatable {
  final int buildings;

  const SubscriptionUsageEntity({required this.buildings});

  @override
  List<Object?> get props => [buildings];
}

class SubscriptionLimitsEntity extends Equatable {
  final int? buildings;

  const SubscriptionLimitsEntity({this.buildings});

  @override
  List<Object?> get props => [buildings];
}

class SubscriptionEntity extends Equatable {
  final String? id;
  final SubscriptionStatus status;
  final String plan;
  /// Backend: `ios` | `android` | `admin_grant`
  final String? platform;
  final DateTime? currentPeriodEnd;
  final SubscriptionUsageEntity? usage;
  final SubscriptionLimitsEntity? limits;

  const SubscriptionEntity({
    this.id,
    required this.status,
    required this.plan,
    this.platform,
    this.currentPeriodEnd,
    this.usage,
    this.limits,
  });

  bool get hasRecord => id != null || status != SubscriptionStatus.unknown;

  bool get isEntitled =>
      status == SubscriptionStatus.active || status == SubscriptionStatus.trial;

  bool get isAdminGrant =>
      (platform ?? '').toLowerCase() == 'admin_grant';

  bool get isBusinessPlan {
    final p = plan.toLowerCase();
    return p.contains('business');
  }

  bool get isAnnualPlan {
    final p = plan.toLowerCase();
    return p.contains('annual') || p.contains('year');
  }

  @override
  List<Object?> get props =>
      [id, status, plan, platform, currentPeriodEnd, usage, limits];
}
