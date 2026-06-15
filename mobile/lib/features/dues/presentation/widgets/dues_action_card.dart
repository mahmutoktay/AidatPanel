import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import 'dues_screen_style.dart';

/// Aidatlar sekmesi üst aksiyon kartı — sol ikon, sağ başlık.
class DuesActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const DuesActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DuesScreenStyle.cardRadius),
        child: Ink(
          decoration: DuesScreenStyle.whiteCard(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.spacingS,
                horizontal: AppSizes.spacingM,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(
                        DuesScreenStyle.iconBoxRadius,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: AppSizes.spacingS),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
