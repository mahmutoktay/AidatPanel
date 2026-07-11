import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/utils/app_intl_locale.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../domain/entities/dekont_entity.dart';
import '../utils/dekont_labels.dart';
import '../utils/dekont_parsed_fields.dart';
import 'dekont_status_banner.dart';

/// Dekont detay — tutar hero + banka/alıcı (+ yönetici: daire/yükleyen/IBAN) + durum bandı.
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
    final visual = dekontDetailStatusVisual(
      context,
      dekont,
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

    final bankName = DekontParsedFields.bankCode(dekont) != null
        ? DekontParsedFields.bankDisplayName(
            t,
            DekontParsedFields.bankCode(dekont),
          )
        : null;
    final receiverName = DekontParsedFields.receiverName(dekont);
    final receiverIban = DekontParsedFields.receiverIban(dekont);
    final apartmentNo = dekont.apartment?.number;
    final residentName = dekont.uploadedBy?.name;
    final buildingName = dekont.buildingName?.trim();
    final referenceNo = dekont.referenceNumber?.trim();

    final showBankReceiver =
        !awaiting && (bankName != null || receiverName != null);
    final managerContextLine = !forResident && !awaiting
        ? _managerContextLine(
            buildingName: buildingName,
            apartmentNo: apartmentNo,
            residentName: residentName,
            apartmentLabel: t.apartment,
          )
        : null;
    final showIban =
        !forResident && !awaiting && receiverIban != null;
    final showReference =
        !forResident && !awaiting && referenceNo != null && referenceNo.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius:
                BorderRadius.circular(DashboardScreenStyle.cardRadius),
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
                            '—',
                            style: AppTypography.h1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 32,
                              height: 1.1,
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
              if (showBankReceiver) ...[
                const SizedBox(height: AppSizes.spacingM),
                Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                const SizedBox(height: AppSizes.spacingM),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _HeroField(
                        label: t.bankLabel,
                        value: bankName ?? '—',
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingM),
                    Expanded(
                      child: _HeroField(
                        label: t.receiverNameLabel,
                        value: receiverName ?? '—',
                      ),
                    ),
                  ],
                ),
              ],
              if (managerContextLine != null) ...[
                const SizedBox(height: AppSizes.spacingM),
                Text(
                  managerContextLine,
                  style: AppTypography.body2.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
              if (showIban) ...[
                const SizedBox(height: AppSizes.spacingM),
                _HeroField(
                  label: t.receiverIbanLabel,
                  value: IbanUtils.normalize(receiverIban),
                  monospace: true,
                ),
              ],
              if (showReference) ...[
                const SizedBox(height: AppSizes.spacingM),
                _HeroField(
                  label: t.referenceNumberLabel,
                  value: referenceNo,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacingM),
        DekontStatusBanner(visual: visual),
      ],
    );
  }

  /// Yeni satır açmadan: `Bina · Daire 5 · Ayşe Yılmaz`
  static String? _managerContextLine({
    required String? buildingName,
    required String? apartmentNo,
    required String? residentName,
    required String apartmentLabel,
  }) {
    final parts = <String>[];
    if (buildingName != null && buildingName.isNotEmpty) {
      parts.add(buildingName);
    }
    if (apartmentNo != null && apartmentNo.isNotEmpty) {
      parts.add('$apartmentLabel $apartmentNo');
    }
    if (residentName != null && residentName.isNotEmpty) {
      parts.add(residentName);
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }
}

class _HeroField extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;

  const _HeroField({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = AppTypography.body1.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      height: 1.3,
      fontFamily: monospace ? 'monospace' : null,
      letterSpacing: monospace ? 0.4 : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: ProfileSettingsUi.fieldLabelUppercase.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
          ),
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
              style: valueStyle,
            ),
          )
        else
          Text(value, style: valueStyle),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final DekontStatusVisual visual;

  const _StatusPill({required this.visual});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: visual.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        visual.label,
        style: AppTypography.caption.copyWith(
          color: visual.color,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
