import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/utils/app_intl_locale.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../domain/entities/dekont_entity.dart';
import '../utils/dekont_labels.dart';
import '../utils/dekont_parsed_fields.dart';
import '../../../buildings/presentation/widgets/building_summary_card.dart';

/// Dekont detay — sol şeritli metrik grid + IBAN/unvan + uyarılar.
class DekontDetailMetricsCard extends StatelessWidget {
  final DekontEntity dekont;
  final bool isManager;

  const DekontDetailMetricsCard({
    super.key,
    required this.dekont,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dekont;
    final languageCode = AppIntlLocale.fromContext(context);
    final visual = dekontStatusVisual(context, dekont.status);
    final awaiting = DekontParsedFields.isAwaitingPipeline(dekont);
    final ibanUnreadable = DekontParsedFields.isIbanUnreadable(dekont);
    final ibanMismatch = DekontParsedFields.isIbanMismatch(dekont);
    final ibanVerified = DekontParsedFields.isIbanVerified(dekont);
    final amount = DekontParsedFields.formattedAmount(dekont);
    final txDate =
        DekontParsedFields.formattedTransactionDate(dekont, locale: languageCode);
    final bankName = DekontParsedFields.bankDisplayName(
      t,
      DekontParsedFields.bankCode(dekont),
    );
    final receiverIban = DekontParsedFields.receiverIban(dekont);
    final receiverName = DekontParsedFields.receiverName(dekont);
    final residentName = dekont.uploadedBy?.name;
    final apartmentNo = dekont.apartment?.number;
    final referenceNo = dekont.referenceNumber?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(BuildingSummaryCard.cardRadius),
            boxShadow: BuildingSummaryCard.cardShadow,
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(BuildingSummaryCard.cardRadius),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: BuildingSummaryCard.statusStripWidth,
                    color: visual.color,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MinimalSectionLabel(title: t.paymentDetailsSection),
                          const SizedBox(height: AppSizes.spacingM),
                          if (awaiting)
                            Text(
                              t.systemInfoProcessing,
                              style: AppTypography.body1.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            )
                          else if (!DekontParsedFields.hasReadableInsights(
                            dekont,
                          ))
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.systemInfoNoData,
                                  style: ProfileSettingsUi.fieldLabelUppercase,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t.systemInfoNoDataHint,
                                  style: AppTypography.body1.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _MetricsGrid(
                              rows: _buildMetricRows(
                                t: t,
                                txDate: txDate,
                                bankName: bankName,
                                apartmentNo: apartmentNo,
                                residentName: residentName,
                                referenceNo: referenceNo,
                              ),
                            ),
                            if (receiverIban != null ||
                                receiverName != null) ...[
                              const SizedBox(height: AppSizes.spacingM),
                              Divider(
                                height: 1,
                                color: AppColors.lineLight,
                              ),
                              const SizedBox(height: AppSizes.spacingM),
                              if (receiverIban != null)
                                _FullWidthField(
                                  label: t.receiverIbanLabel,
                                  value: IbanUtils.normalize(receiverIban),
                                  monospace: true,
                                ),
                              if (receiverName != null) ...[
                                if (receiverIban != null)
                                  const SizedBox(height: AppSizes.spacingS),
                                _FullWidthField(
                                  label: t.receiverNameLabel,
                                  value: receiverName,
                                ),
                              ],
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (ibanUnreadable && !awaiting) ...[
          const SizedBox(height: AppSizes.spacingS),
          _CompactNotice(
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
            background: AppColors.warningBg,
            message: t.ibanUnreadableNotice,
          ),
        ] else if (ibanMismatch) ...[
          const SizedBox(height: AppSizes.spacingS),
          _CompactNotice(
            icon: Icons.error_outline_rounded,
            color: AppColors.error,
            background: AppColors.errorBg,
            message: t.ibanMismatchNotice,
          ),
        ] else if (ibanVerified) ...[
          const SizedBox(height: AppSizes.spacingS),
          _CompactNotice(
            icon: Icons.verified_outlined,
            color: AppColors.success,
            background: AppColors.successBg,
            message: t.ibanVerifiedNotice,
          ),
        ],
        if (dekont.status.needsManagerApproval && !awaiting) ...[
          const SizedBox(height: AppSizes.spacingS),
          _CompactNotice(
            icon: isManager
                ? Icons.account_balance_wallet_outlined
                : Icons.pending_actions_outlined,
            color: AppColors.primary,
            background: AppColors.infoBg,
            message: isManager
                ? _managerSummary(
                    t,
                    residentName: residentName,
                    apartmentNo: apartmentNo,
                    txDate: txDate,
                    bankName: bankName,
                    amount: amount,
                    languageCode: languageCode,
                  )
                : t.residentPendingReviewNotice,
          ),
          if (isManager) ...[
            const SizedBox(height: AppSizes.spacingXS),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                t.managerApprovalHint,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
        if (dekont.rejectionReason != null &&
            dekont.rejectionReason!.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spacingS),
          _CompactNotice(
            icon: Icons.block_rounded,
            color: AppColors.error,
            background: AppColors.errorBg,
            message: '${t.rejectionReason}: ${dekont.rejectionReason}',
          ),
        ],
      ],
    );
  }

  List<List<_MetricCellData?>> _buildMetricRows({
    required dynamic t,
    required String? txDate,
    required String bankName,
    required String? apartmentNo,
    required String? residentName,
    required String? referenceNo,
  }) {
    final rows = <List<_MetricCellData?>>[];

    void addRow(_MetricCellData? left, _MetricCellData? right) {
      if (left == null && right == null) return;
      rows.add([left, right]);
    }

    addRow(
      txDate != null
          ? _MetricCellData(label: t.transactionDateLabel as String, value: txDate)
          : null,
      DekontParsedFields.bankCode(dekont) != null
          ? _MetricCellData(label: t.bankLabel as String, value: bankName)
          : null,
    );
    addRow(
      apartmentNo != null
          ? _MetricCellData(label: t.apartment as String, value: apartmentNo)
          : null,
      residentName != null
          ? _MetricCellData(label: t.uploadedBy as String, value: residentName)
          : null,
    );
    if (referenceNo != null && referenceNo.isNotEmpty) {
      addRow(
        _MetricCellData(
          label: t.referenceNumberLabel as String,
          value: referenceNo,
        ),
        null,
      );
    }

    return rows;
  }

  String _managerSummary(
    dynamic t, {
    required String? residentName,
    required String? apartmentNo,
    required String? txDate,
    required String bankName,
    required String? amount,
    required String languageCode,
  }) {
    final who = _residentLabel(t, residentName, apartmentNo);
    final dateText = txDate ??
        AppDateFormat.dateMedium(dekont.createdAt, languageCode: languageCode);
    final bankText = DekontParsedFields.bankCode(dekont) != null
        ? bankName
        : t.bankUnknown as String;
    final amountText = amount ?? t.amountUnknown as String;

    return (t.managerPaymentSummary as String)
        .replaceAll('{resident}', who)
        .replaceAll('{date}', dateText)
        .replaceAll('{bank}', bankText)
        .replaceAll('{amount}', amountText);
  }

  String _residentLabel(
    dynamic t,
    String? name,
    String? apartmentNo,
  ) {
    if (name != null && apartmentNo != null) {
      return (t.residentWithApartment as String)
          .replaceAll('{name}', name)
          .replaceAll('{apartment}', apartmentNo);
    }
    if (name != null) return name;
    if (apartmentNo != null) {
      return (t.apartmentOnly as String).replaceAll('{apartment}', apartmentNo);
    }
    return t.residentUnknown as String;
  }
}

class _MetricCellData {
  final String label;
  final String value;

  const _MetricCellData({required this.label, required this.value});
}

class _MetricsGrid extends StatelessWidget {
  final List<List<_MetricCellData?>> rows;

  const _MetricsGrid({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSizes.spacingS),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildCell(rows[i][0])),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(child: _buildCell(rows[i].length > 1 ? rows[i][1] : null)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCell(_MetricCellData? data) {
    if (data == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.label.toUpperCase(),
          style: ProfileSettingsUi.fieldLabelUppercase,
        ),
        const SizedBox(height: 4),
        Text(
          data.value,
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _FullWidthField extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;

  const _FullWidthField({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: ProfileSettingsUi.fieldLabelUppercase,
        ),
        const SizedBox(height: 4),
        if (monospace)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              softWrap: false,
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                letterSpacing: 0.4,
                height: 1.2,
              ),
            ),
          )
        else
          Text(
            value,
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
      ],
    );
  }
}

class _CompactNotice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String message;

  const _CompactNotice({
    required this.icon,
    required this.color,
    required this.background,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
