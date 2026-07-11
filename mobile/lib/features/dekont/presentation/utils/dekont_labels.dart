import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/dekont_entity.dart';
import '../../domain/entities/dekont_status.dart';
import 'dekont_parsed_fields.dart';

class DekontStatusVisual {
  final String label;
  final Color color;
  final Color background;
  final String? description;
  final IconData icon;

  const DekontStatusVisual({
    required this.label,
    required this.color,
    required this.background,
    this.description,
    this.icon = Icons.info_outline_rounded,
  });
}

DekontStatusVisual dekontStatusVisual(
  BuildContext context,
  DekontStatus status,
) {
  final t = context.t.features.dekont;
  switch (status) {
    case DekontStatus.received:
    case DekontStatus.extracting:
    case DekontStatus.matching:
      return DekontStatusVisual(
        label: status == DekontStatus.extracting
            ? t.statusExtracting
            : status == DekontStatus.matching
                ? t.statusMatching
                : t.statusReceived,
        color: AppColors.info,
        background: AppColors.infoBg,
        icon: Icons.hourglass_top_rounded,
      );
    case DekontStatus.extractFailed:
    case DekontStatus.recipientMismatch:
    case DekontStatus.unmatched:
      return DekontStatusVisual(
        label: _statusLabel(t, status),
        color: AppColors.error,
        background: AppColors.errorBg,
        icon: Icons.error_outline_rounded,
      );
    case DekontStatus.rejected:
      return DekontStatusVisual(
        label: t.statusRejected,
        color: AppColors.error,
        background: AppColors.errorBg,
        icon: Icons.block_rounded,
      );
    case DekontStatus.paymentApplied:
    case DekontStatus.matched:
      return DekontStatusVisual(
        label: status == DekontStatus.paymentApplied
            ? t.statusPaymentApplied
            : t.statusMatched,
        color: AppColors.success,
        background: AppColors.successBg,
        icon: status == DekontStatus.paymentApplied
            ? Icons.check_circle_outline_rounded
            : Icons.verified_outlined,
      );
    case DekontStatus.needsManagerReview:
    case DekontStatus.parseLowConfidence:
    case DekontStatus.matchAmbiguous:
    case DekontStatus.parsed:
      return DekontStatusVisual(
        label: _statusLabel(t, status),
        color: AppColors.warning,
        background: AppColors.warningBg,
        icon: Icons.pending_actions_outlined,
      );
    case DekontStatus.paymentPartial:
      return DekontStatusVisual(
        label: t.statusPaymentPartial,
        color: AppColors.accent,
        background: AppColors.warningBg,
        icon: Icons.payments_outlined,
      );
  }
}

/// Sakin ekranları — teknik pipeline yerine ürün dili (işleniyor / onay bekliyor / onaylandı / red).
DekontStatusVisual residentDekontStatusVisual(
  BuildContext context,
  DekontStatus status, {
  DekontEntity? dekont,
}) {
  final r = context.t.features.dekont.resident;
  final t = context.t.features.dekont;

  switch (status) {
    case DekontStatus.received:
    case DekontStatus.extracting:
    case DekontStatus.matching:
    case DekontStatus.parsed:
      return DekontStatusVisual(
        label: r.statusProcessing,
        color: AppColors.info,
        background: AppColors.infoBg,
        description: r.statusDetailProcessing,
        icon: Icons.hourglass_top_rounded,
      );
    case DekontStatus.needsManagerReview:
    case DekontStatus.parseLowConfidence:
    case DekontStatus.matchAmbiguous:
    case DekontStatus.matched:
    case DekontStatus.unmatched:
    case DekontStatus.recipientMismatch:
    case DekontStatus.extractFailed:
      return DekontStatusVisual(
        label: r.statusAwaitingApproval,
        color: AppColors.warning,
        background: AppColors.warningBg,
        description: _residentAwaitingDescription(r, dekont),
        icon: Icons.pending_actions_outlined,
      );
    case DekontStatus.paymentApplied:
      return DekontStatusVisual(
        label: r.statusApproved,
        color: AppColors.success,
        background: AppColors.successBg,
        description: r.statusDetailApproved,
        icon: Icons.check_circle_outline_rounded,
      );
    case DekontStatus.paymentPartial:
      return DekontStatusVisual(
        label: r.statusPartiallyApproved,
        color: AppColors.accent,
        background: AppColors.warningBg,
        description: r.statusDetailPartiallyApproved,
        icon: Icons.payments_outlined,
      );
    case DekontStatus.rejected:
      final reason = dekont?.rejectionReason?.trim();
      final description = (reason != null && reason.isNotEmpty)
          ? '${r.statusDetailRejected} ${t.rejectionReason}: $reason'
          : r.statusDetailRejected;
      return DekontStatusVisual(
        label: r.statusRejected,
        color: AppColors.error,
        background: AppColors.errorBg,
        description: description,
        icon: Icons.block_rounded,
      );
  }
}

String _residentAwaitingDescription(dynamic r, DekontEntity? dekont) {
  if (dekont == null) return r.statusDetailAwaitingApproval as String;
  if (DekontParsedFields.isIbanVerified(dekont)) {
    return r.statusDetailAwaitingIbanOk as String;
  }
  if (DekontParsedFields.isIbanMismatch(dekont) ||
      DekontParsedFields.isIbanUnreadable(dekont)) {
    return r.statusDetailAwaitingIbanIssue as String;
  }
  return r.statusDetailAwaitingApproval as String;
}

/// Yönetici detay — sakin ile aynı ürün kovaları; daire/sakin bağlamı için kısa açıklama.
DekontStatusVisual managerDekontDetailVisual(
  BuildContext context,
  DekontStatus status, {
  DekontEntity? dekont,
}) {
  final m = context.t.features.dekont.manager;
  final t = context.t.features.dekont;

  switch (status) {
    case DekontStatus.received:
    case DekontStatus.extracting:
    case DekontStatus.matching:
    case DekontStatus.parsed:
      return DekontStatusVisual(
        label: m.statusProcessing,
        color: AppColors.info,
        background: AppColors.infoBg,
        description: m.statusDetailProcessing,
        icon: Icons.hourglass_top_rounded,
      );
    case DekontStatus.needsManagerReview:
    case DekontStatus.parseLowConfidence:
    case DekontStatus.matchAmbiguous:
    case DekontStatus.matched:
    case DekontStatus.unmatched:
    case DekontStatus.recipientMismatch:
    case DekontStatus.extractFailed:
      return DekontStatusVisual(
        label: m.statusAwaitingApproval,
        color: AppColors.warning,
        background: AppColors.warningBg,
        description: _managerAwaitingDescription(m, dekont),
        icon: Icons.pending_actions_outlined,
      );
    case DekontStatus.paymentApplied:
      return DekontStatusVisual(
        label: m.statusApproved,
        color: AppColors.success,
        background: AppColors.successBg,
        description: m.statusDetailApproved,
        icon: Icons.check_circle_outline_rounded,
      );
    case DekontStatus.paymentPartial:
      return DekontStatusVisual(
        label: m.statusPartiallyApproved,
        color: AppColors.accent,
        background: AppColors.warningBg,
        description: m.statusDetailPartiallyApproved,
        icon: Icons.payments_outlined,
      );
    case DekontStatus.rejected:
      final reason = dekont?.rejectionReason?.trim();
      final description = (reason != null && reason.isNotEmpty)
          ? '${m.statusDetailRejected} ${t.rejectionReason}: $reason'
          : m.statusDetailRejected;
      return DekontStatusVisual(
        label: m.statusRejected,
        color: AppColors.error,
        background: AppColors.errorBg,
        description: description,
        icon: Icons.block_rounded,
      );
  }
}

String _managerAwaitingDescription(dynamic m, DekontEntity? dekont) {
  if (dekont == null) return m.statusDetailAwaitingApproval as String;
  if (DekontParsedFields.isIbanVerified(dekont)) {
    return m.statusDetailAwaitingIbanOk as String;
  }
  if (DekontParsedFields.isIbanMismatch(dekont) ||
      DekontParsedFields.isIbanUnreadable(dekont)) {
    return m.statusDetailAwaitingIbanIssue as String;
  }
  return m.statusDetailAwaitingApproval as String;
}

/// Detay ekranı: sakin/yönetici ürün dili. Liste ekranı yönetici için [dekontStatusVisual] kullanır.
DekontStatusVisual dekontDetailStatusVisual(
  BuildContext context,
  DekontEntity dekont, {
  required bool forResident,
}) {
  return forResident
      ? residentDekontStatusVisual(context, dekont.status, dekont: dekont)
      : managerDekontDetailVisual(context, dekont.status, dekont: dekont);
}

DekontStatusVisual dekontStatusVisualForRole(
  BuildContext context,
  DekontStatus status, {
  required bool forResident,
  DekontEntity? dekont,
}) {
  return forResident
      ? residentDekontStatusVisual(context, status, dekont: dekont)
      : dekontStatusVisual(context, status);
}

String _statusLabel(dynamic t, DekontStatus status) {
  switch (status) {
    case DekontStatus.received:
      return t.statusReceived as String;
    case DekontStatus.extracting:
      return t.statusExtracting as String;
    case DekontStatus.extractFailed:
      return t.statusExtractFailed as String;
    case DekontStatus.parsed:
      return t.statusParsed as String;
    case DekontStatus.parseLowConfidence:
      return t.statusParseLowConfidence as String;
    case DekontStatus.matching:
      return t.statusMatching as String;
    case DekontStatus.matched:
      return t.statusMatched as String;
    case DekontStatus.matchAmbiguous:
      return t.statusMatchAmbiguous as String;
    case DekontStatus.unmatched:
      return t.statusUnmatched as String;
    case DekontStatus.paymentApplied:
      return t.statusPaymentApplied as String;
    case DekontStatus.paymentPartial:
      return t.statusPaymentPartial as String;
    case DekontStatus.rejected:
      return t.statusRejected as String;
    case DekontStatus.recipientMismatch:
      return t.statusRecipientMismatch as String;
    case DekontStatus.needsManagerReview:
      return t.statusNeedsManagerReview as String;
  }
}

bool dekontMatchesUiFilter(DekontStatus status, String? filterKey) {
  if (filterKey == null || filterKey.isEmpty) return true;
  switch (filterKey) {
    case 'pending':
      return status.needsManagerApproval ||
          status.isProcessing ||
          status == DekontStatus.received;
    case 'approved':
      return status == DekontStatus.paymentApplied ||
          status == DekontStatus.paymentPartial;
    case 'rejected':
      return status == DekontStatus.rejected;
    default:
      return true;
  }
}

List<DekontEntity> filterDekontsByUiKey(
  List<DekontEntity> dekonts,
  String? filterKey,
) {
  if (filterKey == null || filterKey.isEmpty) return dekonts;
  return dekonts
      .where((d) => dekontMatchesUiFilter(d.status, filterKey))
      .toList(growable: false);
}
