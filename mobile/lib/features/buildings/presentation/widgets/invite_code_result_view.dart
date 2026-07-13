import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../domain/entities/building_entity.dart';
import '../../utils/invite_code_helpers.dart';
import '../utils/apartment_ui_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';

/// Adım 3: Üretilen davet kodunu gösteren ve aksiyonları sunan görünüm.
class InviteCodeResultView extends StatelessWidget {
  final String code;
  final BuildingEntity building;
  final ApartmentEntity apartment;
  final DateTime expiresAt;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onRevoke;
  final VoidCallback onPickAnother;
  final VoidCallback onGoHome;
  final bool showPickAnother;

  const InviteCodeResultView({
    super.key,
    required this.code,
    required this.building,
    required this.apartment,
    required this.expiresAt,
    required this.onCopy,
    required this.onShare,
    required this.onRevoke,
    required this.onPickAnother,
    required this.onGoHome,
    this.showPickAnother = true,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = expiresAt.difference(DateTime.now());
    final items = <Widget>[
      _buildSuccessBanner(context),
      const SizedBox(height: AppSizes.spacingL),
      _buildCodeCard(context, remaining),
      const SizedBox(height: AppSizes.spacingL),
      _InviteCopyShareActions(onCopy: onCopy, onShare: onShare),
      const SizedBox(height: AppSizes.spacingM),
      _buildInfoNote(context),
      const SizedBox(height: AppSizes.spacingM),
      _buildSecondaryActions(context),
      const SizedBox(height: AppSizes.spacingL),
      _buildHomeButton(context),
    ];
    return ListView.builder(
      key: const ValueKey('step-2'),
      padding: AppSizes.screenBodyScrollPadding,
      itemCount: items.length,
      itemBuilder: (_, i) => items[i],
    );
  }

  Widget _buildSuccessBanner(BuildContext context) {
    final apartmentLabel = ApartmentUiUtils.formatApartmentLabel(
      context,
      apartment.apartmentNumber,
    );

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: DashboardScreenStyle.whiteCard(),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            context.t.features.buildings.codeReady,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            InviteCodeHelpers.resultSubtitle(
              building: building,
              apartmentLabel: apartmentLabel,
            ),
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard(BuildContext context, Duration remaining) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: DashboardScreenStyle.whiteCard(),
      child: Column(
        children: [
          Text(
            context.t.features.buildings.code,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: AppSizes.spacingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.brand.withValues(alpha: 0.12),
              ),
            ),
            child: SelectableText(
              code,
              style: AppTypography.h2.copyWith(
                color: AppColors.brand,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                fontFamily: 'monospace',
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.warning),
                const SizedBox(width: 6),
                Text(
                  context.t.features.buildings.validFor7Days,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            '${context.t.common.expiresAtPrefix}: ${InviteCodeHelpers.formatDate(expiresAt)}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '${context.t.common.remainingPrefix}: ${InviteCodeHelpers.remainingText(remaining)}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.t.features.buildings.activeCodeNote,
              style: AppTypography.body2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActions(BuildContext context) {
    if (!showPickAnother) {
      return SizedBox(
        height: AppSizes.buttonHeightSecondary,
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onRevoke,
          style: AppButtonStyles.outlinedDanger(fullWidth: true),
          icon: const Icon(Icons.cancel_outlined),
          label: Text(context.t.features.buildings.cancelCode),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: OutlinedButton.icon(
              onPressed: onPickAnother,
              style: AppButtonStyles.outlinedNeutral(fullWidth: true),
              icon: const Icon(Icons.list_alt_rounded),
              label: Text(context.t.features.buildings.anotherApartment),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: OutlinedButton.icon(
              onPressed: onRevoke,
              style: AppButtonStyles.outlinedDanger(fullWidth: true),
              icon: const Icon(Icons.cancel_outlined),
              label: Text(context.t.features.buildings.cancelCode),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeightPrimary,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onGoHome,
        style: AppButtonStyles.elevatedPrimary(fullWidth: true),
        icon: const Icon(Icons.home_rounded),
        label: Text(context.t.features.buildings.backToMainMenu),
      ),
    );
  }
}

class _InviteCopyShareActions extends StatefulWidget {
  const _InviteCopyShareActions({
    required this.onCopy,
    required this.onShare,
  });

  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  State<_InviteCopyShareActions> createState() => _InviteCopyShareActionsState();
}

class _InviteCopyShareActionsState extends State<_InviteCopyShareActions> {
  static const _copyResetDuration = Duration(seconds: 2);
  static const _copyButtonWidth = 168.0;

  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _handleCopy() {
    widget.onCopy();
    _resetTimer?.cancel();
    setState(() => _copied = true);
    _resetTimer = Timer(_copyResetDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final buildingsT = context.t.features.buildings;

    return Row(
      children: [
        SizedBox(
          width: _copyButtonWidth,
          height: AppSizes.buttonHeightPrimary,
          child: ElevatedButton(
            onPressed: _handleCopy,
            style: AppButtonStyles.elevatedPrimary(fullWidth: true),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _copied
                  ? Row(
                      key: const ValueKey('copied'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded, size: 20),
                        const SizedBox(width: 6),
                        Text(buildingsT.copyDone),
                      ],
                    )
                  : Row(
                      key: const ValueKey('copy'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.copy_rounded, size: 20),
                        const SizedBox(width: 6),
                        Text(buildingsT.copy),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacingM),
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightPrimary,
            child: OutlinedButton.icon(
              onPressed: widget.onShare,
              style: AppButtonStyles.outlinedPrimary(fullWidth: true),
              icon: const Icon(Icons.person_add_outlined),
              label: Text(context.t.common.inviteResident),
            ),
          ),
        ),
      ],
    );
  }
}
