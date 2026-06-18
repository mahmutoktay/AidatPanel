import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../utils/apartment_ui_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';

/// Dolu daireye yine de yeni kod üretilmek istendiğinde gösterilen onay sheet'i.
class OccupiedApartmentConfirmDialog extends StatelessWidget {
  final ApartmentEntity apartment;
  final VoidCallback onConfirm;

  const OccupiedApartmentConfirmDialog({
    super.key,
    required this.apartment,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required ApartmentEntity apartment,
    required VoidCallback onConfirm,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => OccupiedApartmentConfirmDialog(
        apartment: apartment,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings;
    final apartmentLabel = ApartmentUiUtils.formatApartmentLabel(
      context,
      apartment.apartmentNumber,
    );

    return PremiumBottomSheetScaffold(
      scrollable: false,
      header: _InviteConfirmHeader(
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.warning,
        title: t.apartmentOccupied,
        subtitle: apartmentLabel,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumSheetMetaRow(
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.primary,
            label: context.t.common.residentPrefix,
            value: apartment.residentName,
          ),
          const PremiumSheetDivider(),
          PremiumSheetMetaRow(
            icon: Icons.door_front_door_outlined,
            iconColor: AppColors.warning,
            label: context.t.common.apartmentsBadge,
            value: apartmentLabel,
          ),
          const SizedBox(height: AppSizes.spacingM),
          _InviteWarningBox(
            child: Text.rich(
              TextSpan(
                style: ProfileSettingsUi.handle.copyWith(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.inkDark,
                ),
                children: [
                  TextSpan(text: t.newCodePrefix),
                  TextSpan(
                    text: t.oldUserRemoved,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: context.t.common.confirmMessage),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: PremiumSheetActions(
        primaryLabel: t.produceAnyway,
        icon: Icons.qr_code_2_rounded,
        dangerPrimary: true,
        onPrimary: () {
          Navigator.pop(context);
          onConfirm();
        },
        secondaryLabel: context.t.common.cancelBtn,
        onSecondary: () => Navigator.pop(context),
      ),
    );
  }
}

/// Aktif kodu iptal etmek için onay sheet'i.
class RevokeInviteCodeDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const RevokeInviteCodeDialog({super.key, required this.onConfirm});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => RevokeInviteCodeDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings;

    return PremiumBottomSheetScaffold(
      scrollable: false,
      header: _InviteConfirmHeader(
        icon: Icons.cancel_outlined,
        iconColor: ProfileSettingsUi.danger,
        title: t.cancelCode,
        subtitle: t.revokeDialog,
      ),
      body: _InviteWarningBox(
        child: Text.rich(
          TextSpan(
            style: ProfileSettingsUi.handle.copyWith(
              fontSize: 15,
              height: 1.4,
              color: AppColors.inkDark,
            ),
            children: [
              TextSpan(text: t.currentCodePrefix),
              TextSpan(
                text: t.codeInvalid,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: context.t.common.confirmMessage),
            ],
          ),
        ),
      ),
      actions: PremiumSheetActions(
        primaryLabel: t.cancelCode,
        dangerPrimary: true,
        onPrimary: () {
          Navigator.pop(context);
          onConfirm();
        },
        secondaryLabel: context.t.common.cancelBtn,
        onSecondary: () => Navigator.pop(context),
      ),
    );
  }
}

class _InviteConfirmHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InviteConfirmHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingL,
        AppSizes.spacingM,
        AppSizes.spacingL,
        AppSizes.spacingS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ProfileSettingsUi.title),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: ProfileSettingsUi.handle.copyWith(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteWarningBox extends StatelessWidget {
  final Widget child;

  const _InviteWarningBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return PremiumSectionBox(
      backgroundColor: AppColors.warning.withValues(alpha: 0.08),
      borderColor: AppColors.warning.withValues(alpha: 0.3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(child: child),
        ],
      ),
    );
  }
}
