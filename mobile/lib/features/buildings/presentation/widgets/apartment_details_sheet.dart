import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/user_profile_avatar.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../../apartments/presentation/widgets/delete_apartment_dialog.dart';
import '../../../apartments/presentation/widgets/edit_apartment_bottom_sheet.dart';
import '../../../apartments/presentation/widgets/remove_resident_dialog.dart';
import '../providers/apartment_dues_history_provider.dart';
import '../utils/apartment_ui_utils.dart';
import 'apartment_account_summary_list.dart';
import 'apartment_details_bottom_toolbar.dart';

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

    if (!isOccupied) {
      return _VacantApartmentSheet(
        pageContext: pageContext,
        apt: apt,
      );
    }

    return _OccupiedApartmentSheet(
      pageContext: pageContext,
      apt: apt,
    );
  }
}

class _VacantApartmentSheet extends StatelessWidget {
  const _VacantApartmentSheet({
    required this.pageContext,
    required this.apt,
  });

  final BuildContext pageContext;
  final ApartmentEntity apt;

  @override
  Widget build(BuildContext context) {
    final apartmentLabel =
        ApartmentUiUtils.formatApartmentLabel(context, apt.apartmentNumber);

    return PremiumBottomSheetScaffold(
      maxHeightFactor: 0.55,
      showCloseButton: true,
      title: apartmentLabel,
      body: Text(
        context.t.common.emptyApartmentAwaitingResident,
        style: AppTypography.body2.copyWith(
          color: AppColors.mutedText,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          height: 1.35,
        ),
      ),
      actions: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacingL,
            AppSizes.spacingS,
            AppSizes.spacingL,
            AppSizes.spacingL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: AppSizes.buttonHeightPrimary,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      ApartmentDetailsSheet._afterApartmentSheetClosed(
                    pageContext,
                    context,
                    () => pageContext.push(
                      '/manager-dashboard/invite-code'
                      '?buildingId=${apt.buildingId}&apartmentId=${apt.id}',
                    ),
                  ),
                  icon: const Icon(Icons.person_add_outlined),
                  label: Text(context.t.common.inviteResident),
                ),
              ),
              const SizedBox(height: AppSizes.spacingS),
              SizedBox(
                height: AppSizes.buttonHeightSecondary,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ApartmentDetailsSheet._afterApartmentSheetClosed(
                    pageContext,
                    context,
                    () => DeleteApartmentDialog.show(
                      pageContext,
                      apartment: apt,
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(context.t.common.deleteApartment),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OccupiedApartmentSheet extends ConsumerWidget {
  const _OccupiedApartmentSheet({
    required this.pageContext,
    required this.apt,
  });

  final BuildContext pageContext;
  final ApartmentEntity apt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusInfo = ApartmentUiUtils.getStatusInfo(context, apt.paymentStatus);
    final phoneText = apt.phone != null
        ? ApartmentUiUtils.formatPhone(apt.phone!)
        : context.t.common.phoneNotShared;
    final historyAsync = ref.watch(
      apartmentDuesHistoryProvider((
        buildingId: apt.buildingId,
        apartmentId: apt.id,
      )),
    );

    return PremiumBottomSheetScaffold(
      maxHeightFactor: 0.9,
      showCloseButton: true,
      title: context.t.common.residentDetailsSheetTitle,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHero(
            apt: apt,
            statusInfo: statusInfo,
          ),
          const SizedBox(height: AppSizes.spacingL),
          _PhoneInfoRow(phoneText: phoneText),
          const SizedBox(height: AppSizes.spacingL),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                final resident = apt.resident!;
                ApartmentDetailsSheet._afterApartmentSheetClosed(
                  pageContext,
                  context,
                  () => pageContext.push(
                    '/manager-dashboard/buildings/${apt.buildingId}'
                    '/apartments/${apt.id}/payment-history'
                    '?apartmentNumber=${Uri.encodeComponent(apt.apartmentNumber)}'
                    '&residentName=${Uri.encodeComponent(resident.name)}',
                  ),
                );
              },
              icon: const Icon(Icons.history_rounded),
              label: Text(context.t.common.viewPaymentHistory),
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            context.t.common.accountSummary,
            style: AppTypography.h4.copyWith(
              color: AppColors.inkDark,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          historyAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.spacingXL),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingL),
              child: Text(
                userFacingError(error),
                style: AppTypography.body2.copyWith(color: AppColors.statusRed),
                textAlign: TextAlign.center,
              ),
            ),
            data: (items) => ApartmentAccountSummaryList(items: items),
          ),
        ],
      ),
      actions: ApartmentDetailsBottomToolbar(
        onEdit: () => ApartmentDetailsSheet._afterApartmentSheetClosed(
          pageContext,
          context,
          () => EditApartmentBottomSheet.show(
            pageContext,
            apartment: apt,
          ),
        ),
        onRemoveResident: () => ApartmentDetailsSheet._afterApartmentSheetClosed(
          pageContext,
          context,
          () => RemoveResidentDialog.show(
            pageContext,
            apartment: apt,
          ),
        ),
      ),
    );
  }
}

class _PhoneInfoRow extends StatelessWidget {
  const _PhoneInfoRow({required this.phoneText});

  final String phoneText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone_outlined,
            color: AppColors.brand,
            size: 22,
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t.features.auth.phone.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phoneText,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
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

class _SheetHero extends ConsumerWidget {
  const _SheetHero({
    required this.apt,
    required this.statusInfo,
  });

  final ApartmentEntity apt;
  final StatusInfo statusInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resident = apt.resident!;
    final apartmentLabel =
        ApartmentUiUtils.formatApartmentLabel(context, apt.apartmentNumber);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserProfileAvatar(
          userId: resident.id,
          userName: resident.name,
          profilePicture: resident.profilePicture,
          size: 64,
        ),
        const SizedBox(width: AppSizes.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resident.name,
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
                  _InfoChip(
                    label: statusInfo.label,
                    color: statusInfo.color,
                    background: statusInfo.bgColor,
                    bordered: true,
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
