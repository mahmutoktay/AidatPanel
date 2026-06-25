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
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PropertyTypePickerSheet(
        currentType: currentType,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.5,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(PremiumBottomSheetScaffold.topRadius),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSizes.spacingS),
              const PremiumSheetHandle(),
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
                        context.t.common.select,
                        style: AppTypography.h3.copyWith(
                          color: AppColors.inkDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: context.t.common.close,
                    ),
                  ],
                ),
              ),
              _PropertyTypeTile(
                icon: Icons.location_city_rounded,
                title: t.tabSites,
                subtitle: t.mySites,
                selected: currentType == PropertyType.sites,
                onTap: () {
                  onSelected(PropertyType.sites);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: AppSizes.spacingS),
              _PropertyTypeTile(
                icon: Icons.apartment_rounded,
                title: t.tabBuildings,
                subtitle: context.t.common.inviteStandaloneBuildings,
                selected: currentType == PropertyType.buildings,
                onTap: () {
                  onSelected(PropertyType.buildings);
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom),
            ],
          ),
        );
      },
    );
  }
}

class _PropertyTypeTile extends StatelessWidget {
  const _PropertyTypeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  static const double _iconBoxSize = 48;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.minTouchTargetComfort,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingL,
              vertical: AppSizes.spacingS,
            ),
            child: Row(
              children: [
                Container(
                  width: _iconBoxSize,
                  height: _iconBoxSize,
                  decoration: BoxDecoration(
                    color: AppColors.dashboardBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: AppColors.statusBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.inkDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mutedText,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: AppSizes.spacingS),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.statusGreen,
                    size: 22,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}