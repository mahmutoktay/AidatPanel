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
<<<<<<< HEAD
  final int? managementUnitsUsed;
  final int? managementUnitsLimit;
=======
  final SubscriptionUsageEntity? usage;
  final SubscriptionLimitsEntity? limits;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

  const SubscriptionEntity({
    this.id,
    required this.status,
    required this.plan,
    this.currentPeriodEnd,
<<<<<<< HEAD
    this.managementUnitsUsed,
    this.managementUnitsLimit,
=======
    this.usage,
    this.limits,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  });

  bool get hasRecord => id != null || status != SubscriptionStatus.unknown;

  @override
<<<<<<< HEAD
  List<Object?> get props => [
        id,
        status,
        plan,
        currentPeriodEnd,
        managementUnitsUsed,
        managementUnitsLimit,
      ];
=======
  List<Object?> get props =>
      [id, status, plan, currentPeriodEnd, usage, limits];
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
}
