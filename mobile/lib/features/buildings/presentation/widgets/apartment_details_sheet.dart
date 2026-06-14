import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxSheetH = MediaQuery.sizeOf(context).height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetH),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSizes.spacingS),
          const _SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacingL,
              AppSizes.spacingM,
              AppSizes.spacingS,
              AppSizes.spacingS,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isOccupied
                        ? context.t.common.residentDetailsSheetTitle
                        : context.t.common.apartmentDetailsSheetTitle,
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: AppSizes.minTouchTarget,
                      height: AppSizes.minTouchTarget,
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.fill,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.spacingL,
                0,
                AppSizes.spacingL,
                AppSizes.spacingM,
              ),
              child: Column(
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
                    _ContactCard(
                      email: resident.email,
                      phone: phoneText,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.spacingL,
              AppSizes.spacingS,
              AppSizes.spacingL,
              AppSizes.spacingM + bottomInset,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSizes.minTouchTargetComfort,
                    child: FilledButton.icon(
                      onPressed: () => ApartmentDetailsSheet._afterApartmentSheetClosed(
                        pageContext,
                        context,
                        () => EditApartmentBottomSheet.show(
                          pageContext,
                          apartment: apt,
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: Text(
                        context.t.common.editApartment,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.buttonRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingS),
                Expanded(
                  child: SizedBox(
                    height: AppSizes.minTouchTargetComfort,
                    child: isOccupied
                        ? OutlinedButton.icon(
                            onPressed: () =>
                                ApartmentDetailsSheet._afterApartmentSheetClosed(
                              pageContext,
                              context,
                              () => RemoveResidentDialog.show(
                                pageContext,
                                apartment: apt,
                              ),
                            ),
                            icon: const Icon(
                              Icons.person_remove_outlined,
                              size: 20,
                            ),
                            label: Text(
                              context.t.common.removeResident,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(
                                color: AppColors.error.withValues(alpha: 0.45),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.buttonRadius,
                                ),
                              ),
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: () =>
                                ApartmentDetailsSheet._afterApartmentSheetClosed(
                              pageContext,
                              context,
                              () => DeleteApartmentDialog.show(
                                pageContext,
                                apartment: apt,
                              ),
                            ),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                            ),
                            label: Text(
                              context.t.common.deleteApartment,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.buttonRadius,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.email,
    required this.phone,
  });

  final String email;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        children: [
          _SheetContactRow(
            icon: Icons.mail_outline_rounded,
            label: context.t.features.auth.email,
            value: email,
          ),
          Divider(
            height: 1,
            indent: AppSizes.spacingM + 44,
            endIndent: AppSizes.spacingM,
            color: AppColors.borderColor.withValues(alpha: 0.35),
          ),
          _SheetContactRow(
            icon: Icons.phone_outlined,
            label: context.t.features.auth.phone,
            value: phone,
          ),
        ],
      ),
    );
  }
}

class _SheetContactRow extends StatelessWidget {
  const _SheetContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
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
