import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/tint_dashboard_tile.dart';
import '../../../../shared/widgets/user_profile_avatar.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../../apartments/presentation/widgets/delete_apartment_dialog.dart';
import '../../../apartments/presentation/widgets/edit_apartment_bottom_sheet.dart';
import '../../../apartments/presentation/widgets/remove_resident_dialog.dart';
import '../utils/apartment_ui_utils.dart';

class ApartmentDetailsSheet {
  static void _afterApartmentSheetClosed(
    BuildContext pageContext,
    BuildContext sheetContext,
    VoidCallback action,
  ) {
    Navigator.of(sheetContext).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageContext.mounted) action();
    });
  }

  static void show(BuildContext context, {required ApartmentEntity apt}) {
    PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (sheetContext) => _ApartmentDetailsSheetBody(
        pageContext: context,
        apt: apt,
      ),
    );
  }
}

class _ApartmentDetailsSheetBody extends ConsumerWidget {
  const _ApartmentDetailsSheetBody({
    required this.pageContext,
    required this.apt,
  });

  final BuildContext pageContext;
  final ApartmentEntity apt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOccupied = apt.isOccupied;
    final resident = apt.resident;
    final statusInfo = ApartmentUiUtils.getStatusInfo(context, apt.paymentStatus);
    final phoneText = apt.phone != null
        ? ApartmentUiUtils.formatPhone(apt.phone!)
        : context.t.common.phoneNotShared;

    return PremiumBottomSheetScaffold(
      maxHeightFactor: 0.85,
      showCloseButton: true,
      title: isOccupied
          ? context.t.common.residentDetailsSheetTitle
          : context.t.common.apartmentDetailsSheetTitle,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHero(
            apt: apt,
            statusInfo: statusInfo,
          ),
          const SizedBox(height: AppSizes.spacingL),
          _StatGrid(apt: apt),
          if (isOccupied && resident != null) ...[
            const SizedBox(height: AppSizes.spacingL),
            PremiumInfoCard(
              children: [
                PremiumInfoRow(
                  icon: Icons.mail_outline_rounded,
                  iconColor: AppColors.primary,
                  label: context.t.features.auth.email,
                  value: resident.email,
                ),
                PremiumInfoRow(
                  icon: Icons.phone_outlined,
                  iconColor: AppColors.primary,
                  label: context.t.features.auth.phone,
                  value: phoneText,
                ),
              ],
            ),
          ],
        ],
      ),
      actions: PremiumSheetActions(
        primaryLabel: context.t.common.editApartment,
        icon: Icons.edit_outlined,
        onPrimary: () => ApartmentDetailsSheet._afterApartmentSheetClosed(
          pageContext,
          context,
          () => EditApartmentBottomSheet.show(
            pageContext,
            apartment: apt,
          ),
        ),
        secondaryLabel: isOccupied
            ? context.t.common.removeResident
            : context.t.common.deleteApartment,
        onSecondary: () {
          if (isOccupied) {
            ApartmentDetailsSheet._afterApartmentSheetClosed(
              pageContext,
              context,
              () => RemoveResidentDialog.show(
                pageContext,
                apartment: apt,
              ),
            );
          } else {
            ApartmentDetailsSheet._afterApartmentSheetClosed(
              pageContext,
              context,
              () => DeleteApartmentDialog.show(
                pageContext,
                apartment: apt,
              ),
            );
          }
        },
      ),
    );
  }
}

class _SheetHero extends ConsumerWidget {
  const _SheetHero({
    required this.apt,
    required this.statusInfo,
  });

  final ApartmentEntity apt;
  final StatusInfo statusInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOccupied = apt.isOccupied;
    final resident = apt.resident;
    final apartmentLabel =
        ApartmentUiUtils.formatApartmentLabel(context, apt.apartmentNumber);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserProfileAvatar(
          userId: resident?.id,
          userName: resident?.name ?? '',
          profilePicture: resident?.profilePicture,
          size: 64,
          isVacant: !isOccupied,
        ),
        const SizedBox(width: AppSizes.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOccupied && resident != null
                    ? resident.name
                    : context.t.common.emptyApartmentText,
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.spacingS),
              Wrap(
                spacing: AppSizes.spacingXS,
                runSpacing: AppSizes.spacingXS,
                children: [
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: apartmentLabel,
                    color: AppColors.textSecondary,
                    background: AppColors.fill,
                  ),
                  if (isOccupied)
                    _InfoChip(
                      label: statusInfo.label,
                      color: statusInfo.color,
                      background: statusInfo.bgColor,
                      bordered: true,
                    )
                  else
                    _InfoChip(
                      label: context.t.common.vacantBadge,
                      color: AppColors.textSecondary,
                      background: AppColors.fill,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.color,
    required this.background,
    this.icon,
    this.bordered = false,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: bordered
            ? Border.all(color: color.withValues(alpha: 0.3))
            : Border.all(color: AppColors.border.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.apt});

  final ApartmentEntity apt;

  @override
  Widget build(BuildContext context) {
    final lastPaymentValue = apt.lastPaymentDate != null
        ? ApartmentUiUtils.formatShortDate(apt.lastPaymentDate!)
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingXS,
        vertical: AppSizes.spacingXS,
      ),
      child: SizedBox(
        height: DashboardMetricTile.kTileHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DashboardMetricTile(
                icon: Icons.receipt_long_outlined,
                label: context.t.common.monthlyDues,
                value: '₺${apt.monthlyDues.toStringAsFixed(0)}',
                animateValue: false,
                backgroundColor: Colors.transparent,
              ),
            ),
            Expanded(
              child: DashboardMetricTile(
                icon: Icons.account_balance_wallet_outlined,
                label: context.t.common.balance,
                value: '₺${apt.balance.toStringAsFixed(0)}',
                animateValue: false,
                backgroundColor: Colors.transparent,
              ),
            ),
            Expanded(
              child: DashboardMetricTile(
                icon: apt.lastPaymentDate != null
                    ? Icons.event_available_outlined
                    : Icons.event_busy_outlined,
                label: context.t.common.lastPayment,
                value: lastPaymentValue,
                animateValue: false,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
