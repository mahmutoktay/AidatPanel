import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/due_transaction_entity.dart';

/// Ortak ödeme/işlem durum chip'i (K8).
class DueTransactionStatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color color;

  const DueTransactionStatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.color,
  });

  factory DueTransactionStatusChip.source(
    BuildContext context,
    DueTransactionSource source,
  ) {
    final t = context.t.features.dues.transactions;
    return DueTransactionStatusChip(
      label: source == DueTransactionSource.receipt
          ? t.sourceReceipt
          : t.sourceManual,
      background: AppColors.infoBg,
      color: AppColors.chartBlue,
    );
  }

  factory DueTransactionStatusChip.status(
    BuildContext context,
    DueTransactionStatus status,
  ) {
    final t = context.t.features.dues.transactions;
    switch (status) {
      case DueTransactionStatus.pending:
        return DueTransactionStatusChip(
          label: t.statusPending,
          background: AppColors.warningBg,
          color: AppColors.chartOrange,
        );
      case DueTransactionStatus.rejected:
        return DueTransactionStatusChip(
          label: t.statusRejected,
          background: AppColors.errorBg,
          color: AppColors.chartRed,
        );
      case DueTransactionStatus.approved:
        return DueTransactionStatusChip(
          label: t.statusApproved,
          background: AppColors.successBg,
          color: AppColors.chartGreen,
        );
    }
  }

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
