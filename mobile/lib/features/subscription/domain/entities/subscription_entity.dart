import 'package:equatable/equatable.dart';

enum SubscriptionStatus { active, expired, cancelled, trial, unknown }

class SubscriptionEntity extends Equatable {
  final String? id;
  final SubscriptionStatus status;
  final String plan;
  final DateTime? currentPeriodEnd;

  const SubscriptionEntity({
    this.id,
    required this.status,
    required this.plan,
    this.currentPeriodEnd,
  });

  bool get hasRecord => id != null || status != SubscriptionStatus.unknown;

  @override
  List<Object?> get props => [id, status, plan, currentPeriodEnd];
}
