import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../theme/profile_settings_ui.dart';

/// Ayarlar → Gizlilik / KVKK / Yardım (placeholder) statik metin ekranı.
enum LegalDocumentKind { privacy, kvkk, help }

class LegalDocumentScreen extends StatelessWidget {
  final LegalDocumentKind kind;

  const LegalDocumentScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final legal = t.legal;
    final title = switch (kind) {
      LegalDocumentKind.privacy => t.common.privacyPolicy,
      LegalDocumentKind.kvkk => t.common.kvkk,
      LegalDocumentKind.help => t.common.helpSupport,
    };

    final intro = switch (kind) {
      LegalDocumentKind.privacy => legal.privacyIntro,
      LegalDocumentKind.kvkk => legal.kvkkIntro,
      LegalDocumentKind.help => legal.helpIntro,
    };

    final sections = switch (kind) {
      LegalDocumentKind.privacy => _privacySections(t),
      LegalDocumentKind.kvkk => _kvkkSections(t),
      LegalDocumentKind.help => [
        _LegalSection(title: legal.helpIntro, body: legal.helpBody),
      ],
    };

    return DashboardSecondaryScaffold(
      title: title,
      body: SingleChildScrollView(
        padding: AppSizes.screenBodyScrollPadding.copyWith(
          bottom: AppSizes.spacingXL + MediaQuery.paddingOf(context).bottom,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.spacingM),
          decoration: DashboardScreenStyle.whiteCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kind != LegalDocumentKind.help) ...[
                Text(
                  '${legal.updatedLabel}: ${legal.updatedDate}',
                  style: ProfileSettingsUi.fieldLabel,
                ),
                const SizedBox(height: AppSizes.spacingM),
              ],
              Text(
                intro,
                style: ProfileSettingsUi.fieldValue.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                ),
              ),
              if (kind != LegalDocumentKind.help) ...[
                const SizedBox(height: AppSizes.spacingL),
                for (final section in sections) ...[
                  Text(
                    section.title,
                    style: ProfileSettingsUi.title.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    section.body,
                    style: ProfileSettingsUi.handle.copyWith(
                      color: ProfileSettingsUi.muted,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                ],
              ] else ...[
                const SizedBox(height: AppSizes.spacingL),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.infoBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.schedule_outlined,
                        color: AppColors.chartBlue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingM),
                    Expanded(
                      child: Text(
                        sections.first.body,
                        style: ProfileSettingsUi.fieldValue.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              Divider(height: AppSizes.spacingXL, color: ProfileSettingsUi.line),
              Text(
                legal.companyName,
                style: ProfileSettingsUi.fieldValue.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXS),
              SelectableText(
                legal.contactEmail,
                style: ProfileSettingsUi.fieldValue.copyWith(
                  color: AppColors.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<_LegalSection> _privacySections(Translations t) {
    final l = t.legal;
    return [
      _LegalSection(title: l.privacyS1Title, body: l.privacyS1Body),
      _LegalSection(title: l.privacyS2Title, body: l.privacyS2Body),
      _LegalSection(title: l.privacyS3Title, body: l.privacyS3Body),
      _LegalSection(title: l.privacyS4Title, body: l.privacyS4Body),
      _LegalSection(title: l.privacyS5Title, body: l.privacyS5Body),
      _LegalSection(title: l.privacyS6Title, body: l.privacyS6Body),
    ];
  }

  static List<_LegalSection> _kvkkSections(Translations t) {
    final l = t.legal;
    return [
      _LegalSection(title: l.kvkkS1Title, body: l.kvkkS1Body),
      _LegalSection(title: l.kvkkS2Title, body: l.kvkkS2Body),
      _LegalSection(title: l.kvkkS3Title, body: l.kvkkS3Body),
      _LegalSection(title: l.kvkkS4Title, body: l.kvkkS4Body),
      _LegalSection(title: l.kvkkS5Title, body: l.kvkkS5Body),
      _LegalSection(title: l.kvkkS6Title, body: l.kvkkS6Body),
    ];
  }
}

class _LegalSection {
  final String title;
  final String body;

  const _LegalSection({required this.title, required this.body});
}
