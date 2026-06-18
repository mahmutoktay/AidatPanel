import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../domain/entities/session_entity.dart';
import '../theme/profile_settings_ui.dart';

class SessionListTile extends StatelessWidget {
  const SessionListTile({
    super.key,
    required this.session,
    required this.onRemove,
    this.isRemoving = false,
  });

  final SessionEntity session;
  final VoidCallback? onRemove;
  final bool isRemoving;

  static const _cardRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).languageCode;
    final cardRadius = BorderRadius.circular(_cardRadius);
    final isCurrent = session.isCurrent;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
        padding: const EdgeInsets.all(AppSizes.spacingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: cardRadius,
          boxShadow: DashboardScreenStyle.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lineLight,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                session.platform == 'ios'
                    ? Icons.phone_iphone_rounded
                    : Icons.smartphone_rounded,
                size: 26,
                color: AppColors.inkDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.deviceLabel,
                          style: ProfileSettingsUi.fieldValue.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.inkDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.fill,
                            borderRadius: BorderRadius.circular(
                              ProfileSettingsUi.radiusPill,
                            ),
                          ),
                          child: Text(
                            t.common.thisDevice,
                            style: ProfileSettingsUi.sectionLabel.copyWith(
                              color: AppColors.mutedText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.common.signedInAt(
                      date: AppDateFormat.dateTimeMedium(
                        session.createdAt,
                        languageCode: locale,
                      ),
                    ),
                    style: ProfileSettingsUi.fieldLabel.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
            if (!isCurrent && onRemove != null) ...[
              const SizedBox(width: 8),
              _SessionRemoveButton(
                isRemoving: isRemoving,
                onPressed: onRemove,
                label: t.common.removeSession,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionRemoveButton extends StatelessWidget {
  const _SessionRemoveButton({
    required this.isRemoving,
    required this.onPressed,
    required this.label,
  });

  final bool isRemoving;
  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isRemoving ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: DashboardScreenStyle.cardShadow,
            ),
            child: Center(
              child: isRemoving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.logout_rounded,
                      color: ProfileSettingsUi.danger,
                      size: 22,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
