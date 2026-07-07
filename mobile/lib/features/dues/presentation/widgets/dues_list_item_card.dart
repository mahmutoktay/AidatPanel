import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../buildings/presentation/utils/apartment_ui_utils.dart';
import '../../domain/entities/due_entity.dart';
import '../utils/dues_ui_helpers.dart';
import 'dues_screen_style.dart';

class DuesListItemCard extends StatelessWidget {
  final DueEntity due;
  final String currencySymbol;
  final bool highlighted;
  final VoidCallback? onTap;

  const DuesListItemCard({
    super.key,
    required this.due,
    required this.currencySymbol,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final visual = duesStatusVisual(context, due.status);
    final meta = dueMetaSubtitle(
      context,
      due,
      currencySymbol: currencySymbol,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DuesScreenStyle.cardRadius),
          child: Ink(
            decoration: DuesScreenStyle.whiteCard().copyWith(
              border: highlighted
                  ? Border.all(color: AppColors.statusBlue, width: 2)
                  : null,
            ),
            padding: const EdgeInsets.all(AppSizes.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: visual.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.door_front_door_rounded,
                    color: visual.fg,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ApartmentUiUtils.formatApartmentLabel(context, due.apartmentNumber)} • ${due.resident?.name ?? context.t.common.vacantBadge}',
                        style: AppTypography.body1.copyWith(
                          color: AppColors.inkDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: visual.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    visual.label,
                    style: AppTypography.caption.copyWith(
                      color: visual.fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
