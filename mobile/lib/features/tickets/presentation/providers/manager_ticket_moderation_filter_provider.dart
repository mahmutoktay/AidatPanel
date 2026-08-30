import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TicketModerationFilter { all, reported, needsReview }

class TicketModerationFilterNotifier extends Notifier<TicketModerationFilter> {
  @override
  TicketModerationFilter build() => TicketModerationFilter.all;

  void select(TicketModerationFilter filter) {
    state = filter;
  }
}

final managerTicketModerationFilterProvider =
    NotifierProvider<TicketModerationFilterNotifier, TicketModerationFilter>(
  TicketModerationFilterNotifier.new,
);
