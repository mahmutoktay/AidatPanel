import 'package:flutter/material.dart';



import '../../../../core/theme/app_colors.dart';

import '../../../../l10n/strings.g.dart';

import '../../domain/entities/dekont_status.dart';



class DekontStatusVisual {

  final String label;

  final Color color;

  final Color background;



  const DekontStatusVisual({

    required this.label,

    required this.color,

    required this.background,

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

      );

    case DekontStatus.extractFailed:

    case DekontStatus.recipientMismatch:

    case DekontStatus.unmatched:

      return DekontStatusVisual(

        label: _statusLabel(t, status),

        color: AppColors.error,

        background: AppColors.errorBg,

      );

    case DekontStatus.rejected:

      return DekontStatusVisual(

        label: t.statusRejected,

        color: AppColors.error,

        background: AppColors.errorBg,

      );

    case DekontStatus.paymentApplied:

    case DekontStatus.matched:

      return DekontStatusVisual(

        label: status == DekontStatus.paymentApplied

            ? t.statusPaymentApplied

            : t.statusMatched,

        color: AppColors.success,

        background: AppColors.successBg,

      );

    case DekontStatus.needsManagerReview:

    case DekontStatus.parseLowConfidence:

    case DekontStatus.matchAmbiguous:

    case DekontStatus.parsed:

      return DekontStatusVisual(

        label: _statusLabel(t, status),

        color: AppColors.warning,

        background: AppColors.warningBg,

      );

    case DekontStatus.paymentPartial:

      return DekontStatusVisual(

        label: t.statusPaymentPartial,

        color: AppColors.accent,

        background: AppColors.warningBg,

      );

  }

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



String? dekontStatusFilterApi(String? filterKey) {

  switch (filterKey) {

    case 'pending':

      return 'NEEDS_MANAGER_REVIEW';

    case 'approved':

      return 'PAYMENT_APPLIED';

    case 'rejected':

      return 'REJECTED';

    default:

      return null;

  }

}

