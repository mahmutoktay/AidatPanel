import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/tint_dashboard_tile.dart';
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
    final isOccupied = apt.isOccupied;
    final resident = apt.resident;
    final statusInfo = ApartmentUiUtils.getStatusInfo(context, apt.paymentStatus);
    final phoneText = apt.phone != null
        ? ApartmentUiUtils.formatPhone(apt.phone!)
        : context.t.common.phoneNotShared;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
        final screenH = MediaQuery.sizeOf(sheetContext).height;
        final maxSheetH = screenH * 0.85;

        return Container(
          constraints: BoxConstraints(maxHeight: maxSheetH),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.spacingS),
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
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
                            ? sheetContext.t.common.residentDetailsSheetTitle
                            : sheetContext.t.common.apartmentDetailsSheetTitle,
                        style: AppTypography.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: () => Navigator.of(sheetContext).pop(),
                      radius: 24,
                      child: Container(
                        width: AppSizes.minTouchTarget,
                        height: AppSizes.minTouchTarget,
                        alignment: Alignment.center,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
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
                      _buildSheetHero(
                        context: sheetContext,
                        apt: apt,
                        statusInfo: statusInfo,
                      ),
                      const SizedBox(height: AppSizes.spacingM),
                      _buildStatGrid(context: sheetContext, apt: apt),
                      if (isOccupied && resident != null) ...[
                        const SizedBox(height: AppSizes.spacingM),
                        _buildContactCard(
                          context: sheetContext,
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
                          onPressed: () => _afterApartmentSheetClosed(
                            context,
                            sheetContext,
                            () => EditApartmentBottomSheet.show(
                              context,
                              apartment: apt,
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          label: Text(
                            sheetContext.t.common.editApartment,
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
                            ? FilledButton.icon(
                                onPressed: () => _afterApartmentSheetClosed(
                                  context,
                                  sheetContext,
                                  () => RemoveResidentDialog.show(
                                    context,
                                    apartment: apt,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.person_remove_outlined,
                                  size: 20,
                                ),
                                label: Text(
                                  sheetContext.t.common.removeResident,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.buttonRadius,
                                    ),
                                  ),
                                ),
                              )
                            : FilledButton.icon(
                                onPressed: () => _afterApartmentSheetClosed(
                                  context,
                                  sheetContext,
                                  () => DeleteApartmentDialog.show(
                                    context,
                                    apartment: apt,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                label: Text(
                                  sheetContext.t.common.deleteApartment,
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
      },
    );
  }

  static Widget _buildSheetHero({
    required BuildContext context,
    required ApartmentEntity apt,
    required StatusInfo statusInfo,
  }) {
    final isOccupied = apt.isOccupied;
    final resident = apt.resident;
    final apartmentLabel = ApartmentUiUtils.formatApartmentLabel(context, apt.apartmentNumber);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            alignment: Alignment.center,
            child: isOccupied && resident != null
                ? Text(
                    ApartmentUiUtils.initialsFromName(resident.name),
                    style: AppTypography.h3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : const Icon(
                    Icons.home_work_outlined,
                    color: AppColors.textSecondary,
                    size: 28,
                  ),
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
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.spacingXS),
                Wrap(
                  spacing: AppSizes.spacingXS,
                  runSpacing: AppSizes.spacingXS,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            apartmentLabel,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isOccupied)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusInfo.bgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusInfo.label,
                          style: AppTypography.caption.copyWith(
                            color: statusInfo.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.borderColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          context.t.common.vacantBadge,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatGrid({
    required BuildContext context,
    required ApartmentEntity apt,
  }) {
    final lastPaymentValue = apt.lastPaymentDate != null
        ? ApartmentUiUtils.formatShortDate(apt.lastPaymentDate!)
        : '—';

    return SizedBox(
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
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: DashboardMetricTile(
              icon: Icons.account_balance_wallet_outlined,
              label: context.t.common.balance,
              value: '₺${apt.balance.toStringAsFixed(0)}',
              animateValue: false,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: DashboardMetricTile(
              icon: apt.lastPaymentDate != null
                  ? Icons.event_available_outlined
                  : Icons.event_busy_outlined,
              label: context.t.common.lastPayment,
              value: lastPaymentValue,
              animateValue: false,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildContactCard({
    required BuildContext context,
    required String email,
    required String phone,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingS),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _SheetContactRow(
              icon: Icons.mail_outline_rounded,
              label: context.t.features.auth.email,
              value: email,
            ),
            const Divider(
              height: 1,
              indent: AppSizes.spacingM,
              endIndent: AppSizes.spacingM,
              color: AppColors.borderColor,
            ),
            _SheetContactRow(
              icon: Icons.phone_outlined,
              label: context.t.features.auth.phone,
              value: phone,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SheetContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primary, size: 20),
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
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
