import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../domain/entities/due_transaction_entity.dart';
import '../providers/due_payment_detail_provider.dart';
import '../utils/dues_ui_helpers.dart';
import 'due_transaction_status_chip.dart';

class DueDetailSheet extends ConsumerWidget {
  const DueDetailSheet({
    super.key,
    required this.due,
    required this.buildingId,
    required this.monthLabel,
    required this.currencySymbol,
    required this.onCollectPayment,
    this.isCollecting = false,
  });

  final DueEntity due;
  final String? buildingId;
  final String monthLabel;
  final String currencySymbol;
  final VoidCallback? onCollectPayment;
  final bool isCollecting;

  static Future<void> show(
    BuildContext context, {
    required DueEntity due,
    required String? buildingId,
    required String monthLabel,
    required String currencySymbol,
    required VoidCallback? onCollectPayment,
    bool isCollecting = false,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => DueDetailSheet(
        due: due,
        buildingId: buildingId,
        monthLabel: monthLabel,
        currencySymbol: currencySymbol,
        onCollectPayment: onCollectPayment,
        isCollecting: isCollecting,
      ),
    );
  }

  bool get _isPaid => due.status == DueStatus.paid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.features.dues;
    final visual = duesStatusVisual(context, due.status);
    final languageCode = AppIntlLocale.fromContext(context);
    final amountText = AppCurrencyFormat.format(
      due.hasRemainingBalance ? due.remainingAmount : due.amount,
      languageCode: languageCode,
      decimalDigits: 0,
    ).replaceAll(AppCurrencyFormat.symbol, currencySymbol);

    final residentName =
        due.resident?.name ?? context.t.common.vacantBadge;
    final apartmentLabel = ApartmentUiUtils.formatApartmentLabel(
      context,
      due.apartmentNumber,
    );

    final paymentAsync = buildingId == null
        ? const AsyncValue<DueTransactionEntity?>.data(null)
        : ref.watch(
            duePaymentDetailProvider((
              buildingId: buildingId!,
              dueId: due.id,
            )),
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
          if (_isPaid && buildingId != null)
            paymentAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: AppSizes.spacingM),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (transaction) {
                if (transaction == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: AppSizes.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      if (transaction.dekontId != null) ...[
                        const SizedBox(height: AppSizes.spacingS),
                        Material(
                          color: AppColors.fill,
                          borderRadius:
                              BorderRadius.circular(AppSizes.cardRadius),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              context.push(
                                '/dekonts/${transaction.dekontId}',
                              );
                            },
                            borderRadius:
                                BorderRadius.circular(AppSizes.cardRadius),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSizes.spacingM),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.infoBg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.receipt_long_outlined,
                                      color: AppColors.chartBlue,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.spacingM),
                                  Expanded(
                                    child: Text(
                                      context.t.features.dekont
                                          .paymentDetailsSection,
                                      style: AppTypography.body2.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.mutedText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      actions: _isPaid
          ? null
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
