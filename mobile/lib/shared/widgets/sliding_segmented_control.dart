import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// İki (veya daha fazla) seçenek arasında kayan pill göstergeli segment kontrolü.
class SlidingSegmentedControl extends StatelessWidget {
  const SlidingSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.enabled = true,
    this.outerBorderRadius = 14,
    this.innerBorderRadius = 10,
    this.height,
    this.fontSize = 15,
  });

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool enabled;
  final double outerBorderRadius;
  final double innerBorderRadius;
  final double? height;
  final double fontSize;

  /// Hafif, parlamayan kayma — göz yormaması için yavaş ve düz eğri.
  static const slideDuration = Duration(milliseconds: 280);
  static const slideCurve = Curves.easeInOut;

  Alignment _alignmentForIndex(int index, int count) {
    if (count <= 1) return Alignment.center;
    final step = 2.0 / (count - 1);
    return Alignment(-1.0 + index * step, 0);
  }

  @override
  Widget build(BuildContext context) {
    assert(segments.isNotEmpty, 'segments must not be empty');
    final safeIndex = selectedIndex.clamp(0, segments.length - 1);
    final controlHeight = height ?? AppSizes.minTouchTargetComfort;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(outerBorderRadius),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / segments.length;

          return SizedBox(
            height: controlHeight,
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment: _alignmentForIndex(safeIndex, segments.length),
                  duration: slideDuration,
                  curve: slideCurve,
                  child: Container(
                    width: segmentWidth,
                    height: controlHeight,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(innerBorderRadius),
                      border: Border.all(
                        color: AppColors.borderColor.withValues(alpha: 0.16),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < segments.length; i++)
                      Expanded(
                        child: _SlidingSegmentTapTarget(
                          label: segments[i],
                          selected: safeIndex == i,
                          enabled: enabled,
                          fontSize: fontSize,
                          onTap: () => onChanged(i),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SlidingSegmentTapTarget extends StatelessWidget {
  const _SlidingSegmentTapTarget({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.fontSize,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: SizedBox(
        height: AppSizes.minTouchTargetComfort,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: SlidingSegmentedControl.slideDuration,
            curve: SlidingSegmentedControl.slideCurve,
            style: AppTypography.body2.copyWith(
              color: selected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary.withValues(alpha: 0.75),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              fontSize: fontSize,
              height: 1.2,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
