import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
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

    return Scaffold(
      backgroundColor: ProfileSettingsUi.background,
      appBar: AppBar(
        backgroundColor: ProfileSettingsUi.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(title, style: ProfileSettingsUi.title),
      ),
      body: ListView(
        padding: ProfileSettingsUi.screenPadding.copyWith(
          bottom: AppSizes.spacingXL + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          if (kind != LegalDocumentKind.help) ...[
            Text(
              '${legal.updatedLabel}: ${legal.updatedDate}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
          ],
          Text(
            intro,
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
          if (kind != LegalDocumentKind.help) ...[
            const SizedBox(height: AppSizes.spacingL),
            for (final section in sections) ...[
              Text(
                section.title,
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                section.body,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),
            ],
          ] else ...[
            const SizedBox(height: AppSizes.spacingL),
            Container(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
                border: ProfileSettingsUi.cardBorder,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                    size: 22,
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Text(
                      sections.first.body,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.spacingM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.spacingM),
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
              border: ProfileSettingsUi.cardBorder,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  legal.companyName,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXS),
                SelectableText(
                  legal.contactEmail,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
