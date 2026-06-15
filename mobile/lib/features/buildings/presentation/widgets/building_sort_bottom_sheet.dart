import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../utils/building_collection_status.dart';

/// Sıralama seçeneklerini gösteren alt sayfa.
class BuildingSortBottomSheet {
  BuildingSortBottomSheet._();

  static Future<BuildingListSort?> show(
    BuildContext context, {
    required BuildingListSort current,
  }) {
    final t = context.t.features.buildings.list;
    final options = BuildingListSort.values;

    return showModalBottomSheet<BuildingListSort>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacingM,
              AppSizes.spacingM,
              AppSizes.spacingM,
              AppSizes.spacingL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.sort,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.inkDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                for (final option in options)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    minTileHeight: AppSizes.minTouchTargetComfort,
                    title: Text(
                      buildingListSortLabel(context, option),
                      style: AppTypography.body1.copyWith(
                        color: AppColors.inkDark,
                        fontWeight: option == current
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: option == current
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.statusGreen,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "Gecikmişe Göre" gibi aktif sıralamayı gösteren chip.
class BuildingSortChip extends StatelessWidget {
  final BuildingListSort sort;
  final VoidCallback onTap;

  const BuildingSortChip({
    super.key,
    required this.sort,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lineLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.minTouchTarget,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    buildingListSortLabel(context, sort),
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: AppTypography.label.copyWith(
                      color: AppColors.inkDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.unfold_more_rounded,
                    size: 18,
                    color: AppColors.mutedText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
