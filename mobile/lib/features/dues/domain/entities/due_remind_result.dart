import 'package:equatable/equatable.dart';

class DueRemindResult extends Equatable {
  final int reminded;
  final int skippedCooldown;

  const DueRemindResult({
    required this.reminded,
    this.skippedCooldown = 0,
  });

  @override
  List<Object?> get props => [reminded, skippedCooldown];
}
