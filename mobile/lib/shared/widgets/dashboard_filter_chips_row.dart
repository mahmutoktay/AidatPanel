import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// Yatay pill chip satırı yüksekliği — chip + üst/alt boşluk.
const double dashboardFilterChipRowHeight = AppSizes.minTouchTarget;

/// Tek pill chip yüksekliği.
const double dashboardFilterChipHeight = 40.0;

/// Pill chip içindeki metin — dikey ortalama için sabit satır yüksekliği.
TextStyle dashboardFilterChipTextStyle({
  required bool selected,
  double fontSize = 15,
}) {
  return AppTypography.body2.copyWith(
    color: selected ? AppColors.surface : AppColors.mutedText,
    fontWeight: FontWeight.w600,
    fontSize: fontSize,
    height: 1.0,
  );
}

const TextHeightBehavior _dashboardFilterChipTextHeight =
    TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
);

/// Genel amaçlı pill filtre chip satırı.
class DashboardFilterChipsRow extends StatelessWidget {
  final List<DashboardFilterChipItem> chips;
  final bool enabled;

  const DashboardFilterChipsRow({
    super.key,
    required this.chips,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: dashboardFilterChipRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSizes.spacingS),
        itemBuilder: (_, i) {
          final chip = chips[i];
          return Center(
            child: DashboardFilterChip(
              label: chip.label,
              selected: chip.selected,
              enabled: enabled,
              onTap: chip.onTap,
            ),
          );
        },
      ),
    );
  }
}

class DashboardFilterChipItem {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const DashboardFilterChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });
}

class DashboardFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const DashboardFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(dashboardFilterChipHeight / 2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: dashboardFilterChipHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: selected ? AppColors.inkDark : AppColors.surface,
            borderRadius: radius,
            border: Border.all(
              color: selected ? AppColors.inkDark : AppColors.lineLight,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            textHeightBehavior: _dashboardFilterChipTextHeight,
            style: dashboardFilterChipTextStyle(selected: selected),
          ),
        ),
      ),
    );
  }
}
