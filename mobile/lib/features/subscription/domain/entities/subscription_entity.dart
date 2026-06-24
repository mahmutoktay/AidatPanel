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
  final DateTime? currentPeriodEnd;
  final SubscriptionUsageEntity? usage;
  final SubscriptionLimitsEntity? limits;

  const SubscriptionEntity({
    this.id,
    required this.status,
    required this.plan,
    this.currentPeriodEnd,
    this.usage,
    this.limits,
  });

  bool get hasRecord => id != null || status != SubscriptionStatus.unknown;

  @override
  List<Object?> get props =>
      [id, status, plan, currentPeriodEnd, usage, limits];
}
