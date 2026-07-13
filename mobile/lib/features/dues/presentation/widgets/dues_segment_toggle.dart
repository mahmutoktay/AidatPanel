import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import 'dues_screen_style.dart';

/// Aidatlar / Giderler / Mülkler segment — aktif sekme aksiyon rengi + kontrast yazı.
class DuesSegmentToggle extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DuesSegmentToggle({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const _duration = Duration(milliseconds: 200);

  Alignment _alignmentForIndex(int index, int count) {
    if (count <= 1) return Alignment.center;
    final step = 2.0 / (count - 1);
    return Alignment(-1.0 + index * step, 0);
  }

  @override
  Widget build(BuildContext context) {
    assert(segments.isNotEmpty, 'segments must not be empty');
    final safeIndex = selectedIndex.clamp(0, segments.length - 1);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(DuesScreenStyle.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / segments.length;
          final controlHeight = AppSizes.minTouchTargetComfort;

          return SizedBox(
            height: controlHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedAlign(
                  alignment: _alignmentForIndex(safeIndex, segments.length),
                  duration: _duration,
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    child: Container(
                      width: segmentWidth,
                      height: controlHeight,
                      decoration: BoxDecoration(
                        color: AppColors.actionButton,
                        borderRadius: BorderRadius.circular(
                          DuesScreenStyle.chipRadius,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    children: [
                      for (var i = 0; i < segments.length; i++)
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onChanged(i),
                              borderRadius: BorderRadius.circular(
                                DuesScreenStyle.chipRadius,
                              ),
                              child: SizedBox(
                                height: controlHeight,
                                child: Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: _duration,
                                    curve: Curves.easeInOut,
                                    style: AppTypography.body2.copyWith(
                                      color: safeIndex == i
                                          ? AppColors.actionButtonForeground
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      height: 1.2,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        segments[i],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
