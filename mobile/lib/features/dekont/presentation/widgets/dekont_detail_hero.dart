import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/utils/app_intl_locale.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../domain/entities/dekont_entity.dart';
import '../utils/dekont_labels.dart';
import '../utils/dekont_parsed_fields.dart';

/// Dekont detay — koyu hero kart (tutar, durum, tarih).
class DekontDetailHero extends StatelessWidget {
  final DekontEntity dekont;
  final bool forResident;

  const DekontDetailHero({
    super.key,
    required this.dekont,
    this.forResident = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dekont;
    final languageCode = AppIntlLocale.fromContext(context);
    final visual = dekontStatusVisualForRole(
      context,
      dekont.status,
      forResident: forResident,
    );
    final awaiting = DekontParsedFields.isAwaitingPipeline(dekont);
    final amount = DekontParsedFields.formattedAmount(dekont);
    final txDate = DekontParsedFields.formattedTransactionDate(
      dekont,
      locale: languageCode,
    );
    final uploadDate = AppDateFormat.dateTimeMedium(dekont.createdAt);

    final subtitle = txDate != null
        ? '${t.transactionDateLabel}: $txDate'
        : uploadDate;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        boxShadow: DashboardScreenStyle.cardShadow,
      ),
      padding: const EdgeInsets.all(AppSizes.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: awaiting
                    ? Text(
                        t.systemInfoProcessing,
                        style: AppTypography.body1.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      )
                    : amount != null
                    ? Text(
                        amount,
                        style: AppTypography.h1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.parsedAmount,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '—',
                            style: AppTypography.h1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 32,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              _StatusPill(visual: visual),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            subtitle,
            style: AppTypography.body2.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final DekontStatusVisual visual;

  const _StatusPill({required this.visual});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: visual.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        visual.label,
        style: AppTypography.caption.copyWith(
          color: visual.color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
