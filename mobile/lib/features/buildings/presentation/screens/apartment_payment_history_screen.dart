import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/app_intl_locale.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../dues/domain/entities/due_transaction_entity.dart';
import '../../../dues/presentation/utils/dues_ui_helpers.dart';
import '../providers/apartment_payment_history_provider.dart';
import '../utils/apartment_ui_utils.dart';

class ApartmentPaymentHistoryScreen extends ConsumerWidget {
  const ApartmentPaymentHistoryScreen({
    super.key,
    required this.buildingId,
    required this.apartmentId,
    required this.apartmentNumber,
    required this.residentName,
  });

  final String buildingId;
  final String apartmentId;
  final String apartmentNumber;
  final String residentName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(
      apartmentPaymentHistoryProvider((
        buildingId: buildingId,
        apartmentId: apartmentId,
      )),
    );
    final apartmentLabel = ApartmentUiUtils.formatApartmentLabel(
      context,
      apartmentNumber,
    );

    return DashboardSecondaryScaffold(
      title: context.t.common.paymentHistoryTitle,
      leading: const Center(child: AppBackButton()),
      fallbackRoute: '/manager-dashboard',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.dashboardScreenPaddingHorizontal,
              AppSizes.spacingM,
              AppSizes.dashboardScreenPaddingHorizontal,
              AppSizes.spacingS,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  residentName,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.inkDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  apartmentLabel,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: AppSizes.screenBodyScrollPadding,
                  child: Text(
                    userFacingError(error),
                    textAlign: TextAlign.center,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.statusRed,
                    ),
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      EmptyStateWidget(
                        icon: Icons.receipt_long_outlined,
                        title: context.t.common.noDuesYet,
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  padding: AppSizes.screenBodyScrollPadding,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
                      child: _PaymentHistoryTile(item: items[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryTile extends StatelessWidget {
  const _PaymentHistoryTile({required this.item});

  final ApartmentPaymentHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final due = item.due;
    final languageCode = AppIntlLocale.fromContext(context);
    final periodLabel = '${monthName(context, due.month)} ${due.year}';
    final statusVisual = duesStatusVisual(context, due.status);
    final amountText = AppCurrencyFormat.format(
      due.amount,
      languageCode: languageCode,
      decimalDigits: 0,
    );
    final txT = context.t.features.dues.transactions;

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
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
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusVisual.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusVisual.label,
                      style: AppTypography.caption.copyWith(
                        color: statusVisual.fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (item.paymentSource != null ||
                      item.transactionStatus != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (item.paymentSource != null)
                          _Chip(
                            label: item.paymentSource ==
                                    DueTransactionSource.receipt
                                ? txT.sourceReceipt
                                : txT.sourceManual,
                            background: AppColors.infoBg,
                            color: AppColors.chartBlue,
                          ),
                        if (item.transactionStatus != null)
                          _Chip(
                            label: _statusLabel(context, item.transactionStatus!),
                            background: _statusBackground(item.transactionStatus!),
                            color: _statusColor(item.transactionStatus!),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
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
    );
  }

  String _statusLabel(BuildContext context, DueTransactionStatus status) {
    final txT = context.t.features.dues.transactions;
    switch (status) {
      case DueTransactionStatus.pending:
        return txT.statusPending;
      case DueTransactionStatus.rejected:
        return txT.statusRejected;
      case DueTransactionStatus.approved:
        return txT.statusApproved;
    }
  }

  Color _statusBackground(DueTransactionStatus status) {
    switch (status) {
      case DueTransactionStatus.pending:
        return AppColors.warningBg;
      case DueTransactionStatus.rejected:
        return AppColors.errorBg;
      case DueTransactionStatus.approved:
        return AppColors.successBg;
    }
  }

  Color _statusColor(DueTransactionStatus status) {
    switch (status) {
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
  const _Chip({
    required this.label,
    required this.background,
    required this.color,
  });

  final String label;
  final Color background;
  final Color color;

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
