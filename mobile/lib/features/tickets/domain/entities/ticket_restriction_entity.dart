import 'package:equatable/equatable.dart';

class TicketRestrictionEntity extends Equatable {
  final String reason;
  final DateTime expiresAt;
  final DateTime createdAt;

  const TicketRestrictionEntity({
    required this.reason,
    required this.expiresAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [reason, expiresAt, createdAt];
}

class TicketRestrictionStatusEntity extends Equatable {
  final bool active;
  final TicketRestrictionEntity? restriction;

  const TicketRestrictionStatusEntity({
    required this.active,
    this.restriction,
  });

  @override
  List<Object?> get props => [active, restriction];
}
