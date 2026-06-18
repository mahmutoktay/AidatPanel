import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../domain/entities/building_entity.dart';

enum BuildingMenuAction { edit, collection, delete }

/// Bina kartı ⋮ menüsü — alt sayfa olarak açılır (PopupMenu yerine).
class BuildingActionsSheet extends StatelessWidget {
  const BuildingActionsSheet({super.key, required this.building});

  final BuildingEntity building;

  static Future<BuildingMenuAction?> show(
    BuildContext context, {
    required BuildingEntity building,
  }) {
    return PremiumBottomSheetScaffold.show<BuildingMenuAction>(
      context: context,
      builder: (_) => BuildingActionsSheet(building: building),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final collectionReady = building.isCollectionConfigured;

    return PremiumBottomSheetScaffold(
      scrollable: false,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            building.name,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (building.displayAddress.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              building.displayAddress,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumActionSheetTile(
            icon: Icons.edit_outlined,
            label: t.common.editBuilding,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedText,
              size: AppSizes.iconSize,
            ),
            onTap: () => Navigator.pop(context, BuildingMenuAction.edit),
          ),
          const SizedBox(height: AppSizes.spacingXS),
          PremiumActionSheetTile(
            icon: collectionReady
                ? Icons.account_balance_wallet_outlined
                : Icons.warning_amber_outlined,
            label: t.features.buildings.collection.menuEdit,
            iconColor:
                collectionReady ? AppColors.textPrimary : AppColors.warning,
            trailing: collectionReady
                ? const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.mutedText,
                    size: AppSizes.iconSize,
                  )
                : const Icon(
                    Icons.warning_amber_rounded,
                    size: AppSizes.iconSizeSmall,
                    color: AppColors.warning,
                  ),
            onTap: () => Navigator.pop(context, BuildingMenuAction.collection),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: AppSizes.spacingM),
          PremiumActionSheetTile(
            icon: Icons.delete_outline,
            label: t.common.deleteBuilding,
            danger: true,
            onTap: () => Navigator.pop(context, BuildingMenuAction.delete),
          ),
        ],
      ),
    );
  }
}
