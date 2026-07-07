import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/app_intl_locale.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../buildings/presentation/utils/apartment_ui_utils.dart';
import '../../domain/entities/due_entity.dart';
import '../utils/dues_ui_helpers.dart';

class DueDetailSheet extends StatelessWidget {
  const DueDetailSheet({
    super.key,
    required this.due,
    required this.monthLabel,
    required this.currencySymbol,
    required this.onCollectPayment,
    this.isCollecting = false,
  });

  final DueEntity due;
  final String monthLabel;
  final String currencySymbol;
  final VoidCallback? onCollectPayment;
  final bool isCollecting;

  static Future<void> show(
    BuildContext context, {
    required DueEntity due,
    required String monthLabel,
    required String currencySymbol,
    required VoidCallback? onCollectPayment,
    bool isCollecting = false,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => DueDetailSheet(
        due: due,
        monthLabel: monthLabel,
        currencySymbol: currencySymbol,
        onCollectPayment: onCollectPayment,
        isCollecting: isCollecting,
      ),
    );
  }

  bool get _isPaid => due.status == DueStatus.paid;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dues;
    final visual = duesStatusVisual(context, due.status);
    final languageCode = AppIntlLocale.fromContext(context);
    final amountText = AppCurrencyFormat.format(
      due.amount,
      languageCode: languageCode,
      decimalDigits: 0,
    ).replaceAll(AppCurrencyFormat.symbol, currencySymbol);

    final residentName =
        due.resident?.name ?? context.t.common.vacantBadge;
    final apartmentLabel = ApartmentUiUtils.formatApartmentLabel(
      context,
      due.apartmentNumber,
    );

    return PremiumBottomSheetScaffold(
      title: t.detailTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$apartmentLabel • $residentName',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          _InfoRow(label: t.periodLabel, value: monthLabel),
          const SizedBox(height: AppSizes.spacingS),
          _InfoRow(label: t.amountLabel, value: amountText),
          const SizedBox(height: AppSizes.spacingS),
          Row(
            children: [
              Text(
                context.t.common.status,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: visual.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  visual.label,
                  style: AppTypography.caption.copyWith(
                    color: visual.fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (_isPaid && due.paidAt != null) ...[
            const SizedBox(height: AppSizes.spacingS),
            _InfoRow(
              label: context.t.common.paidStatus,
              value: duePaidSummary(context, due),
            ),
          ],
        ],
      ),
      actions: _isPaid
          ? PremiumSheetActions(
              primaryLabel: t.paymentDetail,
              onPrimary: () {
                Navigator.pop(context);
                context.push('/manager-dashboard/due-transactions');
              },
            )
          : PremiumSheetActions(
              primaryLabel: t.collectPayment,
              primaryLoading: isCollecting,
              primaryEnabled: onCollectPayment != null && !isCollecting,
              onPrimary: onCollectPayment,
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
