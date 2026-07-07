import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/utils/app_intl_locale.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/due_transaction_entity.dart';

class DueTransactionTile extends StatelessWidget {
  final DueTransactionEntity transaction;
  final VoidCallback? onTap;

  const DueTransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dues.transactions;
    final languageCode = AppIntlLocale.fromContext(context);
    final title = _title(t);
    final subtitle = _subtitle(context, t);
    final amountText = transaction.amount == null
        ? '—'
        : AppCurrencyFormat.format(
            transaction.amount!,
            languageCode: languageCode,
            decimalDigits: 0,
          );

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Chip(
                          label: transaction.source == DueTransactionSource.receipt
                              ? t.sourceReceipt
                              : t.sourceManual,
                          background: AppColors.infoBg,
                          color: AppColors.chartBlue,
                        ),
                        _Chip(
                          label: _statusLabel(t),
                          background: _statusBackground(),
                          color: _statusColor(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Text(
                amountText,
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(dynamic t) {
    final apt = transaction.apartmentNumber;
    final resident = transaction.residentName;
    if (resident != null && resident.isNotEmpty) {
      if (apt != null && apt.isNotEmpty) {
        return '$apt · $resident';
      }
      return resident;
    }
    if (apt != null && apt.isNotEmpty) {
      return apt;
    }
    return t.unknownApartment;
  }

  String _subtitle(BuildContext context, dynamic t) {
    final date = AppDateFormat.dateMedium(
      transaction.occurredAt,
      languageCode: AppIntlLocale.fromContext(context),
    );
    return date;
  }

  String _statusLabel(dynamic t) {
    switch (transaction.status) {
      case DueTransactionStatus.pending:
        return t.statusPending;
      case DueTransactionStatus.rejected:
        return t.statusRejected;
      case DueTransactionStatus.approved:
        return t.statusApproved;
    }
  }

  Color _statusBackground() {
    switch (transaction.status) {
      case DueTransactionStatus.pending:
        return AppColors.warningBg;
      case DueTransactionStatus.rejected:
        return AppColors.errorBg;
      case DueTransactionStatus.approved:
        return AppColors.successBg;
    }
  }

  Color _statusColor() {
    switch (transaction.status) {
      case DueTransactionStatus.pending:
        return AppColors.chartOrange;
      case DueTransactionStatus.rejected:
        return AppColors.chartRed;
      case DueTransactionStatus.approved:
        return AppColors.chartGreen;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color background;
  final Color color;

  const _Chip({
    required this.label,
    required this.background,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
