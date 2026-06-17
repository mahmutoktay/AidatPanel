import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
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

    return PremiumBottomSheetScaffold.show<BuildingListSort>(
      context: context,
      builder: (context) => PremiumBottomSheetScaffold(
        title: t.sort,
        scrollable: false,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSizes.spacingXS),
              PremiumActionSheetTile(
                icon: Icons.sort_rounded,
                label: buildingListSortLabel(context, options[i]),
                trailing: options[i] == current
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.statusGreen,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(options[i]),
              ),
            ],
          ],
        ),
      ),
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
                    style: const TextStyle(
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
