import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../models/building_list_item_model.dart';
import 'building_summary_card.dart';

/// Tek bina kartı — durum şeridi, metrikler, progress bar ve rozet.
class BuildingListCard extends StatelessWidget {
  final BuildingListItemModel item;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onCollection;
  final VoidCallback? onDelete;

  const BuildingListCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onEdit,
    this.onCollection,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(BuildingSummaryCard.cardRadius),
          child: BuildingSummaryCard(
            item: item,
            trailing: _buildMenu(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final buildingsT = context.t.features.buildings;
    return PopupMenuButton<String>(
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.mutedText,
        size: AppSizes.iconSize,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: AppSizes.minTouchTarget,
        minHeight: AppSizes.minTouchTarget,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
          case 'collection':
            onCollection?.call();
          case 'delete':
            onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Text(context.t.common.edit),
        ),
        PopupMenuItem(
          value: 'collection',
          child: Text(buildingsT.collection.menuEdit),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            context.t.common.delete,
            style: const TextStyle(color: AppColors.statusRed),
          ),
        ),
      ],
    );
  }
}
