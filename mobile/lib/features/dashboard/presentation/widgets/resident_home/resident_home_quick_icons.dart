import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';

/// Üst sıra — beyaz kare kart + renkli ikon kutusu (mockup 5).
class ResidentHomeTopShortcutCard extends StatelessWidget {
  const ResidentHomeTopShortcutCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconBackground,
    required this.onTap,
    this.iconColor = Colors.white,
    this.iconShape = BoxShape.rectangle,
  });

  final String label;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final BoxShape iconShape;
  final VoidCallback onTap;

  static const _cardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            height: 118,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
              boxShadow: _cardShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconShape == BoxShape.circle ? 44 : 40,
                  height: iconShape == BoxShape.circle ? 44 : 40,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: iconShape,
                    borderRadius: iconShape == BoxShape.rectangle
                        ? BorderRadius.circular(10)
                        : null,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(height: AppSizes.spacingS),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.2,
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
