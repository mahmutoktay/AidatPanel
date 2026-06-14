import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/dekont_entity.dart';
import '../utils/dekont_labels.dart';
import '../utils/dekont_parsed_fields.dart';

/// Ana sayfa dashboard kutuları ile aynı: çerçevesiz fill zemin.
const _kTileRadius = 12.0;

class DekontSystemInfoSection extends StatelessWidget {
  final DekontEntity dekont;
  final bool isManager;

  const DekontSystemInfoSection({
    super.key,
    required this.dekont,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dekont;
    final locale = Localizations.localeOf(context).toString();
    final visual = dekontStatusVisual(context, dekont.status);
    final awaiting = DekontParsedFields.isAwaitingPipeline(dekont);
    final ibanUnreadable = DekontParsedFields.isIbanUnreadable(dekont);
    final ibanMismatch = DekontParsedFields.isIbanMismatch(dekont);
    final ibanVerified = DekontParsedFields.isIbanVerified(dekont);
    final amount = DekontParsedFields.formattedAmount(dekont);
    final txDate =
        DekontParsedFields.formattedTransactionDate(dekont, locale: locale);
    final bankName = DekontParsedFields.bankDisplayName(
      t,
      DekontParsedFields.bankCode(dekont),
    );
    final receiverIban = DekontParsedFields.receiverIban(dekont);
    final receiverName = DekontParsedFields.receiverName(dekont);
    final residentName = dekont.uploadedBy?.name;
    final apartmentNo = dekont.apartment?.number;

    final fields = <_FieldData>[];
    if (!awaiting) {
      if (txDate != null) {
        fields.add(
          _FieldData(
            icon: Icons.calendar_today_outlined,
            label: t.transactionDateLabel,
            value: txDate,
          ),
        );
      }
      if (DekontParsedFields.bankCode(dekont) != null) {
        fields.add(
          _FieldData(
            icon: Icons.account_balance_outlined,
            label: t.bankLabel,
            value: bankName,
          ),
        );
      }
      if (receiverIban != null) {
        fields.add(
          _FieldData(
            icon: Icons.credit_card_outlined,
            label: t.receiverIbanLabel,
            value: IbanUtils.normalize(receiverIban),
            monospace: true,
          ),
        );
      }
      if (receiverName != null) {
        fields.add(
          _FieldData(
            icon: Icons.person_outline_rounded,
            label: t.receiverNameLabel,
            value: receiverName,
          ),
        );
      }
      if (dekont.referenceNumber != null &&
          dekont.referenceNumber!.isNotEmpty) {
        fields.add(
          _FieldData(
            icon: Icons.tag_outlined,
            label: t.referenceNumberLabel,
            value: dekont.referenceNumber!,
          ),
        );
      }
      if (apartmentNo != null) {
        fields.add(
          _FieldData(
            icon: Icons.door_front_door_outlined,
            label: t.apartment,
            value: apartmentNo,
          ),
        );
      }
      if (residentName != null) {
        fields.add(
          _FieldData(
            icon: Icons.upload_outlined,
            label: t.uploadedBy,
            value: residentName,
          ),
        );
      }
      if (!DekontParsedFields.hasReadableInsights(dekont)) {
        fields.add(
          _FieldData(
            icon: Icons.info_outline_rounded,
            label: t.systemInfoNoData,
            value: t.systemInfoNoDataHint,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: BorderRadius.circular(_kTileRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingL,
            vertical: AppSizes.spacingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (awaiting)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        t.systemInfoProcessing,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    _StatusChip(
                      label: visual.label,
                      color: visual.color,
                      background: visual.background,
                    ),
                  ],
                )
              else ...[
                if (amount != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const _FieldLeadingIcon(icon: Icons.payments_outlined),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.parsedAmount,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              amount,
                              style: AppTypography.h2.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      _StatusChip(
                        label: visual.label,
                        color: visual.color,
                        background: visual.background,
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: _StatusChip(
                      label: visual.label,
                      color: visual.color,
                      background: visual.background,
                    ),
                  ),
                for (final field in fields) _FieldRow(field: field),
              ],
            ],
          ),
        ),
        if (ibanUnreadable && !awaiting) ...[
          const SizedBox(height: AppSizes.spacingM),
          _NoticeBar(
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
            message: t.ibanUnreadableNotice,
          ),
        ] else if (ibanMismatch) ...[
          const SizedBox(height: AppSizes.spacingM),
          _NoticeBar(
            icon: Icons.error_outline_rounded,
            color: AppColors.error,
            message: t.ibanMismatchNotice,
          ),
        ] else if (ibanVerified) ...[
          const SizedBox(height: AppSizes.spacingM),
          _NoticeBar(
            icon: Icons.verified_outlined,
            color: AppColors.success,
            message: t.ibanVerifiedNotice,
          ),
        ],
        if (dekont.status.needsManagerApproval && !awaiting) ...[
          const SizedBox(height: AppSizes.spacingM),
          _NoticeBar(
            icon: isManager
                ? Icons.account_balance_wallet_outlined
                : Icons.pending_actions_outlined,
            color: AppColors.primary,
            message: isManager
                ? _managerSummary(
                    t,
                    residentName: residentName,
                    apartmentNo: apartmentNo,
                    txDate: txDate,
                    bankName: bankName,
                    amount: amount,
                    locale: locale,
                  )
                : t.residentPendingReviewNotice,
          ),
          if (isManager) ...[
            const SizedBox(height: AppSizes.spacingS),
            Text(
              t.managerApprovalHint,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
        if (dekont.rejectionReason != null &&
            dekont.rejectionReason!.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spacingM),
          _NoticeBar(
            icon: Icons.block_rounded,
            color: AppColors.error,
            message: '${t.rejectionReason}: ${dekont.rejectionReason}',
          ),
        ],
      ],
    );
  }

  String _managerSummary(
    dynamic t, {
    required String? residentName,
    required String? apartmentNo,
    required String? txDate,
    required String bankName,
    required String? amount,
    required String locale,
  }) {
    final who = _residentLabel(t, residentName, apartmentNo);
    final dateText = txDate ??
        DateFormat('d MMMM yyyy', locale).format(dekont.createdAt.toLocal());
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

class _FieldData {
  final IconData icon;
  final String label;
  final String value;
  final bool monospace;

  const _FieldData({
    required this.icon,
    required this.label,
    required this.value,
    this.monospace = false,
  });
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FieldLeadingIcon extends StatelessWidget {
  final IconData icon;

  const _FieldLeadingIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 20,
      color: AppColors.textSecondary,
    );
  }
}

class _FieldRow extends StatelessWidget {
  final _FieldData field;

  const _FieldRow({required this.field});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _FieldLeadingIcon(icon: field.icon),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                if (field.monospace)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      field.value,
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
                    field.value,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeBar extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _NoticeBar({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(_kTileRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacingM),
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
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
