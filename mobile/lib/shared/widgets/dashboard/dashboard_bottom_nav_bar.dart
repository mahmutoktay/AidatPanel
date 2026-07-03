import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_typography.dart';
import '../../theme/dashboard_screen_style.dart';

/// Dashboard alt sekme geçiş süresi — yönetici ve sakin aynı.
abstract final class DashboardNavAnimation {
  static const Duration duration = Duration(milliseconds: 200);
  static const Curve curve = Curves.easeInOut;
}

class DashboardNavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const DashboardNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Alt navigasyon — kaydırmalı pill vurgusu, parlamasız yumuşak geçiş.
class DashboardBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<DashboardNavDestination> destinations;
  final Color? selectedAccentColor;
  final bool showSelectionPill;

  const DashboardBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.selectedAccentColor,
    this.showSelectionPill = true,
  });

  static const double _barHeight = 56.0;
  static const double _pillHorizontalInset = 4;

  @override
  Widget build(BuildContext context) {
    final count = destinations.length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.lineLight, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingS,
            vertical: 8.0,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / count;

              return SizedBox(
                height: _barHeight,
                width: constraints.maxWidth,
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    if (showSelectionPill)
                      AnimatedPositioned(
                        duration: DashboardNavAnimation.duration,
                        curve: DashboardNavAnimation.curve,
                        left: (selectedIndex * tabWidth) + _pillHorizontalInset,
                        top: 0,
                        bottom: 0,
                        width: tabWidth - (_pillHorizontalInset * 2),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.fill,
                            borderRadius: BorderRadius.circular(
                              DashboardScreenStyle.navActivePillRadius,
                            ),
                          ),
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < count; i++)
                          Expanded(
                            child: _NavItem(
                              destination: destinations[i],
                              selected: selectedIndex == i,
                              selectedAccentColor: selectedAccentColor,
                              onTap: () => onDestinationSelected(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final DashboardNavDestination destination;
  final bool selected;
  final Color? selectedAccentColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.selected,
    this.selectedAccentColor,
    required this.onTap,
  });

  static const double _iconSize = 24;
  static const double _iconLabelGap = 4;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        duration: DashboardNavAnimation.duration,
        curve: DashboardNavAnimation.curve,
        tween: Tween<double>(end: selected ? 1 : 0),
        builder: (context, emphasis, _) {
          final color = Color.lerp(
            AppColors.mutedText,
            selectedAccentColor ?? AppColors.textPrimary,
            emphasis,
          )!;
          final fontWeight = FontWeight.lerp(
            FontWeight.w600,
            FontWeight.w700,
            emphasis,
          );

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  color: color,
                  size: _iconSize,
                ),
                const SizedBox(height: _iconLabelGap),
                Text(
                  destination.label,
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: fontWeight,
                    fontSize: 12,
                    height: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
