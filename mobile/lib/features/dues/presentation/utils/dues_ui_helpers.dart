import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/utils/app_intl_locale.dart';
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

/// Sakin ekranları — kullanıcıya doğrudan hitap eden durum etiketleri.
DuesStatusVisual residentDuesStatusVisual(BuildContext context, DueStatus status) {
  final r = context.t.features.dues.resident;
  switch (status) {
    case DueStatus.paid:
      return DuesStatusVisual(
        label: r.paidStatus,
        fg: AppColors.statusGreen,
        bg: AppColors.statusGreenBg,
        icon: Icons.check_rounded,
      );
    case DueStatus.overdue:
      return DuesStatusVisual(
        label: r.overdueStatus,
        fg: AppColors.statusRed,
        bg: AppColors.statusRedBg,
        icon: Icons.warning_amber_rounded,
      );
    case DueStatus.waived:
      return DuesStatusVisual(
        label: r.waivedStatus,
        fg: AppColors.mutedText,
        bg: AppColors.dashboardBackground,
        icon: Icons.remove_circle_outline,
      );
    case DueStatus.pending:
      return DuesStatusVisual(
        label: r.pendingStatus,
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

int _overdueDayCount(DueEntity due) {
  if (due.overdueDays > 0) return due.overdueDays;
  final dueDate = due.dueDate;
  if (dueDate == null) return 0;
  final diff = DateTime.now().difference(dueDate).inDays;
  return diff > 0 ? diff : 0;
}

/// Ödendi özeti: "7 Temmuz 2026" veya "7 Temmuz 2026 - 3 gün gecikti".
String duePaidSummary(BuildContext context, DueEntity due) {
  final paidAt = due.paidAt;
  if (paidAt == null) return context.t.common.paidStatus;

  final languageCode = AppIntlLocale.fromContext(context);
  final dateStr = AppDateFormat.dateMedium(
    paidAt,
    languageCode: languageCode,
  );
  final lateDays = latePaymentDays(due);
  if (lateDays != null && lateDays > 0) {
    return context.t.common.duePaidSummaryLate
        .replaceAll('{date}', dateStr)
        .replaceAll('{days}', '$lateDays');
  }
  return dateStr;
}

/// Duruma özgü kısa özet (liste alt satırı, hesap geçmişi vb.).
String dueStatusDetail(BuildContext context, DueEntity due) {
  switch (due.status) {
    case DueStatus.overdue:
      return context.t.common.dueMetaOverdueDelay
          .replaceAll('{days}', '${_overdueDayCount(due)}');
    case DueStatus.paid:
      return duePaidSummary(context, due);
    case DueStatus.pending:
      final dueDay = due.dueDate?.day;
      if (dueDay != null) {
        return context.t.common.dueMetaPendingDueDate
            .replaceAll('{day}', '$dueDay')
            .replaceAll('{month}', monthName(context, due.month));
      }
      return context.t.common.dueDateLabel;
    case DueStatus.waived:
      return context.t.common.waivedStatus;
  }
}

String dueListRowSubtitle(
  BuildContext context,
  DueEntity due, {
  required String currencySymbol,
}) {
  final period = '${monthName(context, due.month)} ${due.year}';
  final amount = '$currencySymbol${due.amount.toStringAsFixed(0)}';
  return '$period · $amount';
}

String dueLatePaymentBadge(BuildContext context, int days) {
  return context.t.common.dueLatePaymentBadge.replaceAll('{days}', '$days');
}

String dueMetaSubtitle(
  BuildContext context,
  DueEntity due, {
  required String currencySymbol,
}) {
  final period = '${monthName(context, due.month)} ${due.year}';
  final amount = '$currencySymbol${due.amount.toStringAsFixed(0)}';
  final statusDetail = dueStatusDetail(context, due);
  return '$period · $amount · $statusDetail';
}

String dueApartmentLabel(BuildContext context, DueEntity due) =>
    '${context.t.common.stepApartment} ${due.apartmentNumber}';

String residentDuePaidSummary(BuildContext context, DueEntity due) {
  final paidAt = due.paidAt;
  final r = context.t.features.dues.resident;
  if (paidAt == null) return r.paidStatus;
  final languageCode = AppIntlLocale.fromContext(context);
  final dateStr = AppDateFormat.dateMedium(
    paidAt,
    languageCode: languageCode,
  );
  final lateDays = latePaymentDays(due);
  if (lateDays != null && lateDays > 0) {
    return r.paidLateSummary
        .replaceAll('{date}', dateStr)
        .replaceAll('{days}', '$lateDays');
  }
  return r.paidOnTimeSummary.replaceAll('{date}', dateStr);
}

String residentDueStatusDetail(BuildContext context, DueEntity due) {
  final r = context.t.features.dues.resident;
  switch (due.status) {
    case DueStatus.overdue:
      return r.overdueDetail.replaceAll('{days}', '${_overdueDayCount(due)}');
    case DueStatus.paid:
      return residentDuePaidSummary(context, due);
    case DueStatus.pending:
      final dueDay = due.dueDate?.day;
      if (dueDay != null) {
        return r.pendingDetail
            .replaceAll('{day}', '$dueDay')
            .replaceAll('{month}', monthName(context, due.month));
      }
      return context.t.common.dueDateLabel;
    case DueStatus.waived:
      return r.waivedStatus;
  }
}

String residentDueCardSubtitle(BuildContext context, DueEntity due) {
  return residentDueStatusDetail(context, due);
}
