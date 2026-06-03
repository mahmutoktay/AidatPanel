import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
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
    return showModalBottomSheet<BuildingMenuAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BuildingActionsSheet(building: building),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final collectionReady = building.isCollectionConfigured;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.spacingM,
        AppSizes.spacingS,
        AppSizes.spacingM,
        AppSizes.spacingM + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetHandle(),
          const SizedBox(height: AppSizes.spacingM),
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
          const SizedBox(height: AppSizes.spacingM),
          _ActionRow(
            icon: Icons.edit_outlined,
            label: t.common.editBuilding,
            onTap: () => Navigator.pop(context, BuildingMenuAction.edit),
          ),
          const SizedBox(height: AppSizes.spacingS),
          _ActionRow(
            icon: collectionReady
                ? Icons.account_balance_wallet_outlined
                : Icons.warning_amber_outlined,
            label: t.features.buildings.collection.menuEdit,
            iconTint:
                collectionReady ? AppColors.textPrimary : AppColors.warning,
            trailing: collectionReady
                ? null
                : Icon(
                    Icons.warning_amber_rounded,
                    size: AppSizes.iconSizeSmall,
                    color: AppColors.warning,
                  ),
            onTap: () => Navigator.pop(context, BuildingMenuAction.collection),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: AppSizes.spacingM),
          _ActionRow(
            icon: Icons.delete_outline,
            label: t.common.deleteBuilding,
            destructive: true,
            onTap: () => Navigator.pop(context, BuildingMenuAction.delete),
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
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconTint,
    this.destructive = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconTint;
  final bool destructive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final accent = destructive
        ? AppColors.error
        : (iconTint ?? AppColors.textPrimary);
    const radius = BorderRadius.all(Radius.circular(12));

    return Material(
      color: AppColors.fill,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.border.withValues(alpha: 0.4),
        highlightColor: AppColors.border.withValues(alpha: 0.25),
        child: SizedBox(
          height: AppSizes.minTouchTargetComfort,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withValues(alpha: 0.18)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 22, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body1.copyWith(
                      color:
                          destructive ? AppColors.error : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSizes.spacingXS),
                  trailing!,
                ],
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
