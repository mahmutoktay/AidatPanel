import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/utils/app_intl_locale.dart';
import '../../../../l10n/strings.g.dart';
import '../../../buildings/presentation/utils/apartment_ui_utils.dart';
import '../../domain/entities/due_transaction_entity.dart';
import 'due_transaction_status_chip.dart';

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
    final title = _title(context, t);
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
                        DueTransactionStatusChip.source(
                          context,
                          transaction.source,
                        ),
                        DueTransactionStatusChip.status(
                          context,
                          transaction.status,
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

  String _title(BuildContext context, dynamic t) {
    final apt = transaction.apartmentNumber;
    final resident = transaction.residentName;
    final aptLabel = (apt != null && apt.trim().isNotEmpty)
        ? ApartmentUiUtils.formatApartmentLabel(context, apt)
        : null;
    if (resident != null && resident.isNotEmpty) {
      if (aptLabel != null && aptLabel.isNotEmpty) {
        return '$aptLabel · $resident';
      }
      return resident;
    }
    if (aptLabel != null && aptLabel.isNotEmpty) {
      return aptLabel;
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
}

