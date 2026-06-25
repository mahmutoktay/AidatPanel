import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/widgets/premium_bottom_sheet.dart';

enum PropertyType { sites, buildings }

class PropertyTypePickerSheet extends StatelessWidget {
  const PropertyTypePickerSheet({
    super.key,
    required this.currentType,
    required this.onSelected,
  });

  final PropertyType currentType;
  final ValueChanged<PropertyType> onSelected;

  static Future<void> show(
    BuildContext context, {
    required PropertyType currentType,
    required ValueChanged<PropertyType> onSelected,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => PropertyTypePickerSheet(
        currentType: currentType,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;

    return PremiumBottomSheetScaffold(
      title: context.t.common.select,
      scrollable: false,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumActionSheetTile(
            icon: Icons.location_city_rounded,
            label: t.tabSites,
            subtitle: t.mySites,
            trailing: currentType == PropertyType.sites
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.statusGreen,
                    size: 22,
                  )
                : null,
            onTap: () {
              onSelected(PropertyType.sites);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: AppSizes.spacingXS),
          PremiumActionSheetTile(
            icon: Icons.apartment_rounded,
            label: t.tabBuildings,
            subtitle: context.t.common.inviteStandaloneBuildings,
            trailing: currentType == PropertyType.buildings
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.statusGreen,
                    size: 22,
                  )
                : null,
            onTap: () {
              onSelected(PropertyType.buildings);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
