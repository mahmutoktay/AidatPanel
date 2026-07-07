import 'package:flutter/widgets.dart';

import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/utils/app_intl_locale.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../l10n/strings.g.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/domain/entities/due_transaction_entity.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/presentation/utils/notification_time.dart';

String residentTransactionPeriodTitle(
  BuildContext context,
  DueTransactionEntity transaction,
  Map<String, DueEntity> duesById,
) {
  final dueId = transaction.dueId;
  if (dueId != null) {
    final due = duesById[dueId];
    if (due != null) {
      return '${localizedMonthName(context, due.month)} ${due.year}';
    }
  }
  final languageCode = AppIntlLocale.fromContext(context);
  return AppDateFormat.monthYear(transaction.occurredAt, languageCode: languageCode);
}

String residentTransactionSubtitle(
  BuildContext context,
  DueTransactionEntity transaction,
) {
  final t = context.t.features.dues.transactions;
  if (transaction.kind == DueTransactionKind.payment) {
    if (transaction.source == DueTransactionSource.receipt) {
      return t.residentPaidByReceipt;
    }
    return t.residentPaidByManual;
  }

  switch (transaction.status) {
    case DueTransactionStatus.rejected:
      return t.residentDekontRejected;
    case DueTransactionStatus.pending:
      return t.residentDekontPending;
    case DueTransactionStatus.approved:
      return t.residentPaidByReceipt;
  }
}

String? residentTransactionTrailing(
  BuildContext context,
  DueTransactionEntity transaction,
) {
  if (transaction.amount == null) return null;
  return AppCurrencyFormat.format(
    transaction.amount!,
    languageCode: AppIntlLocale.fromContext(context),
    decimalDigits: 0,
  );
}

String residentAnnouncementTitle(BuildContext context, NotificationEntity notification) {
  final time = notificationRelativeTime(context, notification.createdAt);
  final label = context.t.features.notifications.resident.announcementFeedLabel;
  return '$time · $label';
}

String residentAnnouncementSubtitle(NotificationEntity notification) {
  final body = notification.body.trim();
  if (body.isNotEmpty) return body;
  return notification.title.trim();
}
