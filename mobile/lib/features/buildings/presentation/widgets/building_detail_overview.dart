import 'package:flutter/material.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../dashboard/domain/entities/manager_dashboard_entities.dart';
import '../../../dashboard/presentation/widgets/manager_home/manager_dues_summary_card.dart';
import '../models/building_list_item_model.dart';
import 'building_summary_card.dart';

/// Bina detay ekranı — kimlik kartı + bankacılık tarzı aidat özeti.
///
/// Sakin yokken / tahsilat verisi yokken `0 / 0 ₺` kartı gösterilmez;
/// isteğe bağlı bekleyen davet sayısı ve davet CTA’sı gösterilir.
class BuildingDetailOverview extends StatelessWidget {
  final BuildingListItemModel item;
  final ManagerDuesAmountSummary summary;
  final String currency;
  final Map<String, List<String>>? remindDueIdsByBuilding;
  final int occupiedApartments;
  final int vacantApartmentCount;
  final int pendingInviteCount;
  final VoidCallback? onInviteResidents;

  const BuildingDetailOverview({
    super.key,
    required this.item,
    required this.summary,
    this.currency = 'TRY',
    this.remindDueIdsByBuilding,
    this.occupiedApartments = 0,
    this.vacantApartmentCount = 0,
    this.pendingInviteCount = 0,
    this.onInviteResidents,
  });

  bool get _showCollectionCard => summary.hasCollectionData;

  bool get _showInviteNudge =>
      !_showCollectionCard &&
      occupiedApartments == 0 &&
      vacantApartmentCount > 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BuildingIdentityCard(
          item: item,
          pendingInviteCount: pendingInviteCount,
          vacantApartmentCount: vacantApartmentCount,
          occupiedApartments: occupiedApartments,
        ),
        if (_showCollectionCard) ...[
          const SizedBox(height: AppSizes.spacingM),
          ManagerDuesSummaryCard(
            summary: summary,
            currency: currency,
            remindDueIdsByBuilding: remindDueIdsByBuilding,
          ),
        ] else if (_showInviteNudge) ...[
          const SizedBox(height: AppSizes.spacingM),
          _NoResidentsInviteCard(onInvite: onInviteResidents),
        ],
      ],
    );
  }
}

class _BuildingIdentityCard extends StatelessWidget {
  final BuildingListItemModel item;
  final int pendingInviteCount;
  final int vacantApartmentCount;
  final int occupiedApartments;

  const _BuildingIdentityCard({
    required this.item,
    required this.pendingInviteCount,
    required this.vacantApartmentCount,
    required this.occupiedApartments,
  });

  String? _statusChipLabel(BuildContext context) {
    if (pendingInviteCount > 0) {
      return context.t.features.dashboard.pendingInvitesCount
          .replaceAll('{count}', '$pendingInviteCount');
    }
    if (occupiedApartments == 0 && vacantApartmentCount > 0) {
      return context.t.features.buildings.list.unitsWaiting
          .replaceAll('{count}', '$vacantApartmentCount');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final chipLabel = _statusChipLabel(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BuildingSummaryCard.cardRadius),
        boxShadow: BuildingSummaryCard.cardShadow,
      ),
      padding: const EdgeInsets.all(AppSizes.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.lineLight,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.apartment_rounded,
              color: AppColors.inkDark,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.sectionTitle.copyWith(
                    color: AppColors.inkDark,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.address.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.address,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (chipLabel != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.statusBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      chipLabel,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.statusBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResidentsInviteCard extends StatelessWidget {
  final VoidCallback? onInvite;

  const _NoResidentsInviteCard({this.onInvite});

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.noResidentsInviteMessage,
            textAlign: TextAlign.center,
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onInvite != null) ...[
            const SizedBox(height: AppSizes.spacingM),
            SizedBox(
              height: AppSizes.buttonHeightSecondary,
              child: ElevatedButton.icon(
                onPressed: onInvite,
                style: AppButtonStyles.elevatedPrimary(fullWidth: true),
                icon: const Icon(Icons.person_add_outlined),
                label: Text(t.noResidentsInviteCta),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
