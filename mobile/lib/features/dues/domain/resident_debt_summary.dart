import 'entities/due_entity.dart';

double dueOutstandingAmount(DueEntity due) {
  if (due.status == DueStatus.paid || due.status == DueStatus.waived) {
    return 0;
  }
  return due.remainingAmount > 0 ? due.remainingAmount : due.amount;
}

double totalOutstandingAmount(List<DueEntity> dues) {
  return dues
      .where(
        (due) =>
            due.status == DueStatus.pending || due.status == DueStatus.overdue,
      )
      .fold<double>(0, (sum, due) => sum + dueOutstandingAmount(due));
}

int overdueDueCount(List<DueEntity> dues) {
  return dues.where((due) => due.status == DueStatus.overdue).length;
}

int pendingDueCount(List<DueEntity> dues) {
  return dues.where((due) => due.status == DueStatus.pending).length;
}

bool hasOutstandingDebt(List<DueEntity> dues) => totalOutstandingAmount(dues) > 0;

DueEntity? pickFeaturedDue(List<DueEntity> dues) {
  final overdue = dues.where((d) => d.status == DueStatus.overdue).toList();
  if (overdue.isNotEmpty) {
    overdue.sort((a, b) => b.overdueDays.compareTo(a.overdueDays));
    return overdue.first;
  }

  final pending = dues.where((d) => d.status == DueStatus.pending).toList();
  if (pending.isNotEmpty) {
    pending.sort((a, b) {
      final aDate = a.dueDate;
      final bDate = b.dueDate;
      if (aDate != null && bDate != null) {
        return aDate.compareTo(bDate);
      }
      if (a.year != b.year) return a.year.compareTo(b.year);
      return a.month.compareTo(b.month);
    });
    return pending.first;
  }

  return null;
}
