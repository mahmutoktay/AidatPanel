import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/due_entity.dart';

class DuesStatusVisual {
  final String label;
  final Color fg;
  final Color bg;
  final IconData icon;

  const DuesStatusVisual({
    required this.label,
    required this.fg,
    required this.bg,
    required this.icon,
  });
}

DuesStatusVisual duesStatusVisual(BuildContext context, DueStatus status) {
  switch (status) {
    case DueStatus.paid:
      return DuesStatusVisual(
        label: context.t.common.paidStatus,
        fg: AppColors.statusGreen,
        bg: AppColors.statusGreenBg,
        icon: Icons.check_rounded,
      );
    case DueStatus.overdue:
      return DuesStatusVisual(
        label: context.t.common.overdueStatus,
        fg: AppColors.statusRed,
        bg: AppColors.statusRedBg,
        icon: Icons.warning_amber_rounded,
      );
    case DueStatus.waived:
      return DuesStatusVisual(
        label: context.t.common.waivedStatus,
        fg: AppColors.mutedText,
        bg: AppColors.dashboardBackground,
        icon: Icons.remove_circle_outline,
      );
    case DueStatus.pending:
      return DuesStatusVisual(
        label: context.t.common.pendingStatus,
        fg: AppColors.statusAmber,
        bg: AppColors.statusAmberBg,
        icon: Icons.schedule_rounded,
      );
  }
}

String monthName(BuildContext context, int month) {
  final t = context.t.common;
  switch (month) {
    case 1:
      return t.monthJanuary;
    case 2:
      return t.monthFebruary;
    case 3:
      return t.monthMarch;
    case 4:
      return t.monthApril;
    case 5:
      return t.monthMay;
    case 6:
      return t.monthJune;
    case 7:
      return t.monthJuly;
    case 8:
      return t.monthAugust;
    case 9:
      return t.monthSeptember;
    case 10:
      return t.monthOctober;
    case 11:
      return t.monthNovember;
    case 12:
      return t.monthDecember;
    default:
      return '$month';
  }
}

/// Ödeme vadesinden sonra yapıldıysa gecikme gün sayısı; yoksa null.
int? latePaymentDays(DueEntity due) {
  if (due.status != DueStatus.paid) return null;
  final paidAt = due.paidAt;
  final dueDate = due.dueDate;
  if (paidAt == null || dueDate == null) return null;

  final paidDay = DateTime(paidAt.year, paidAt.month, paidAt.day);
  final deadline = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final diff = paidDay.difference(deadline).inDays;
  return diff > 0 ? diff : null;
}

String dueMetaSubtitle(
  BuildContext context,
  DueEntity due, {
  required String currencySymbol,
}) {
  final period =
      '${monthName(context, due.month)} ${due.year}';
  final amount =
      '$currencySymbol${due.amount.toStringAsFixed(0)}';

  final String statusDetail;
  switch (due.status) {
    case DueStatus.overdue:
      statusDetail = context.t.common.dueMetaOverdueDelay
          .replaceAll('{days}', '${due.overdueDays}');
    case DueStatus.paid:
      final paidMonth = due.paidAt != null
          ? monthName(context, due.paidAt!.month)
          : monthName(context, due.month);
      final paidYear = due.paidAt?.year ?? due.year;
      statusDetail = context.t.common.dueMetaPaidInMonth
          .replaceAll('{month}', paidMonth)
          .replaceAll('{year}', '$paidYear');
    case DueStatus.pending:
      final dueDay = due.dueDate?.day;
      statusDetail = dueDay != null
          ? context.t.common.dueMetaPendingDueDate
              .replaceAll('{day}', '$dueDay')
              .replaceAll('{month}', monthName(context, due.month))
          : context.t.common.dueDateLabel;
    case DueStatus.waived:
      statusDetail = context.t.common.waivedStatus;
  }

  return '$period · $amount · $statusDetail';
}

String dueApartmentLabel(BuildContext context, DueEntity due) =>
    '${context.t.common.stepApartment} ${due.apartmentNumber}';

String? duePaidOnDaySubtitle(BuildContext context, DueEntity due) {
  if (due.status != DueStatus.paid || due.paidAt == null) return null;
  return context.t.common.dueMetaPaidOnDay
      .replaceAll('{day}', due.paidAt!.day.toString().padLeft(2, '0'))
      .replaceAll('{month}', monthName(context, due.paidAt!.month));
}

String residentDueCardSubtitle(BuildContext context, DueEntity due) {
  final apartment = dueApartmentLabel(context, due);
  final paidOn = duePaidOnDaySubtitle(context, due);
  if (paidOn != null) return '$apartment · $paidOn';
  return apartment;
}
