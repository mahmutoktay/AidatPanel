import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/app_intl_locale.dart';
import '../../../../l10n/strings.g.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/domain/entities/due_transaction_entity.dart';
import '../../../dues/presentation/utils/dues_ui_helpers.dart';
import '../providers/apartment_dues_history_provider.dart';

class ApartmentAccountSummaryList extends StatelessWidget {
  const ApartmentAccountSummaryList({
    super.key,
    required this.items,
  });

  final List<ApartmentDueHistoryItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingL),
        child: Center(
          child: Text(
            context.t.common.noDuesYet,
            style: AppTypography.body2.copyWith(color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          ApartmentAccountSummaryTile(item: items[i]),
          if (i < items.length - 1)
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderColor.withValues(alpha: 0.25),
            ),
        ],
      ],
    );
  }
}

class ApartmentAccountSummaryTile extends StatelessWidget {
  const ApartmentAccountSummaryTile({
    super.key,
    required this.item,
  });

  final ApartmentDueHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final due = item.due;
    final languageCode = AppIntlLocale.fromContext(context);
    final periodLabel =
        '${monthName(context, due.month)} ${due.year}';
    final statusVisual = duesStatusVisual(context, due.status);
    final statusLabel = _statusLabel(context, due);
    final amountText = AppCurrencyFormat.format(
      due.amount,
      languageCode: languageCode,
      decimalDigits: 0,
    );
    final paymentLabel = _paymentMethodLabel(context, item.paymentSource);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  periodLabel,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLabel,
                  style: AppTypography.body2.copyWith(
                    color: statusVisual.fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (paymentLabel != null) ...[
                  const SizedBox(height: 8),
                  _PaymentMethodChip(label: paymentLabel),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Text(
            amountText,
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(BuildContext context, DueEntity due) {
    return dueStatusDetail(context, due);
  }

  String? _paymentMethodLabel(
    BuildContext context,
    DueTransactionSource? source,
  ) {
    if (source == null) return null;
    final t = context.t;
    return switch (source) {
      DueTransactionSource.receipt => t.features.dekont.paymentMethodEft,
      DueTransactionSource.manual => t.features.dues.transactions.sourceManual,
    };
  }
}

class _PaymentMethodChip extends StatelessWidget {
  const _PaymentMethodChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.chartBlue,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
