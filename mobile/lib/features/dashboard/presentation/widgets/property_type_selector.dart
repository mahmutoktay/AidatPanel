import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/theme/dashboard_screen_style.dart';
import 'property_type_picker_sheet.dart';

class PropertyTypeSelector extends StatelessWidget {
  const PropertyTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.siteCount = 0,
    this.buildingCount = 0,
  });

  final PropertyType selectedType;
  final ValueChanged<PropertyType> onChanged;
  final int siteCount;
  final int buildingCount;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;

    final title =
        selectedType == PropertyType.sites ? t.tabSites : t.tabBuildings;
    final subtitle = selectedType == PropertyType.sites
        ? t.siteCount.replaceAll('{count}', '$siteCount')
        : t.buildingCount.replaceAll('{count}', '$buildingCount');

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => PropertyTypePickerSheet.show(
            context,
            currentType: selectedType,
            onSelected: onChanged,
            siteCount: siteCount,
            buildingCount: buildingCount,
          ),
          borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
          child: Ink(
            decoration: DashboardScreenStyle.whiteCard(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.dashboardBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      selectedType == PropertyType.sites
                          ? Icons.location_city_rounded
                          : Icons.apartment_rounded,
                      color: AppColors.statusBlue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.inkDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 26,
                    color: AppColors.mutedText.withValues(alpha: 0.45),
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
