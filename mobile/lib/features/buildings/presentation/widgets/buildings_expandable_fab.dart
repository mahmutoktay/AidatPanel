import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';

/// Binalar sekmesi sağ-alt genişleyen "+ Yeni" FAB.
class BuildingsExpandableFab extends StatefulWidget {
  const BuildingsExpandableFab({
    super.key,
    required this.onNewBuilding,
    this.onNewSite,
    this.showSiteAction = true,
    this.showBuildingAction = true,
    this.onExpandedChanged,
  });

  final VoidCallback onNewBuilding;
  final VoidCallback? onNewSite;
  final bool showSiteAction;
  final bool showBuildingAction;
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<BuildingsExpandableFab> createState() => BuildingsExpandableFabState();
}

class BuildingsExpandableFabState extends State<BuildingsExpandableFab>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 200);

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setExpanded(bool value) {
    if (_expanded == value) return;
    setState(() => _expanded = value);
    widget.onExpandedChanged?.call(value);
    if (value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _toggle() => _setExpanded(!_expanded);

  void close() => _setExpanded(false);

  void _onNewBuilding() {
    close();
    widget.onNewBuilding();
  }

  void _onNewSite() {
    close();
    widget.onNewSite?.call();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings;

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizeTransition(
            sizeFactor: _expandAnimation,
            axis: Axis.vertical,
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.showSiteAction) ...[
                    _ExpandFabAction(
                      label: t.newSite,
                      icon: Icons.domain_add_outlined,
                      onTap: _onNewSite,
                    ),
                    const SizedBox(height: AppSizes.spacingS),
                  ],
                  if (widget.showBuildingAction) ...[
                    _ExpandFabAction(
                      label: t.newBuildingShort,
                      icon: Icons.add_business_outlined,
                      onTap: _onNewBuilding,
                    ),
                    const SizedBox(height: AppSizes.spacingS),
                  ],
                ],
              ),
            ),
          ),
          FloatingActionButton.extended(
            onPressed: _toggle,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: AnimatedRotation(
              turns: _expanded ? 0.125 : 0,
              duration: _animationDuration,
              curve: Curves.easeInOut,
              child: const Icon(Icons.add_rounded),
            ),
            label: Text(
              t.fabNew,
              style: AppTypography.button.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandFabAction extends StatelessWidget {
  const _ExpandFabAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: AppSizes.spacingS,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: AppSizes.spacingS),
                Text(
                  label,
                  style: AppTypography.button.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
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

/// FAB açıkken arka planı karartır ve dokununca kapatır.
class BuildingsExpandableFabOverlay extends StatelessWidget {
  const BuildingsExpandableFabOverlay({
    super.key,
    required this.visible,
    required this.onClose,
  });

  final bool visible;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}
