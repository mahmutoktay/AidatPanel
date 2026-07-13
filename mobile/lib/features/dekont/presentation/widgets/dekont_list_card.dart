import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../domain/entities/dekont_entity.dart';
import '../utils/dekont_labels.dart';

class DekontListCard extends StatelessWidget {
  final DekontEntity dekont;
  final VoidCallback onTap;
  final String? apartmentLabel;
  final String? uploaderLabel;

  final bool forResident;

  const DekontListCard({
    super.key,
    required this.dekont,
    required this.onTap,
    this.apartmentLabel,
    this.uploaderLabel,
    this.forResident = false,
  });

  @override
  Widget build(BuildContext context) {
    final visual = dekontStatusVisualForRole(
      context,
      dekont.status,
      forResident: forResident,
    );
    final date = AppDateFormat.dateShort(dekont.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        onTap: onTap,
        child: Ink(
          decoration: DashboardScreenStyle.whiteCard(),
          padding: const EdgeInsets.all(AppSizes.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: visual.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: visual.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Text(
                      dekont.originalFilename,
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: visual.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      visual.label,
                      style: AppTypography.caption.copyWith(
                        color: visual.color,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingXS),
              Text(
                date,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (apartmentLabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  apartmentLabel!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (uploaderLabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  uploaderLabel!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (dekont.parsedAmount != null) ...[
                const SizedBox(height: 4),
                Text(
                  dekont.parsedAmount!,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.brand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
