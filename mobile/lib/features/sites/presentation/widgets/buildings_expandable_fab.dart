import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';

/// Sekme bağlamına göre Yeni Site / Yeni Bina seçeneklerini açan FAB.
class BuildingsExpandableFab extends StatefulWidget {
  final bool showSiteAction;
  final bool showBuildingAction;

  const BuildingsExpandableFab({
    super.key,
    this.showSiteAction = true,
    this.showBuildingAction = true,
  });

  @override
  State<BuildingsExpandableFab> createState() => _BuildingsExpandableFabState();
}

class _BuildingsExpandableFabState extends State<BuildingsExpandableFab>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 200);
  static const _curve = Curves.easeInOut;

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          setState(() {});
        }
      });
    _expandAnimation = CurvedAnimation(parent: _controller, curve: _curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _closeAndNavigate(VoidCallback action) {
    if (_open) _toggle();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final actions = <_FabAction>[];
    if (widget.showSiteAction) {
      actions.add(
        _FabAction(
          label: t.newSite,
          icon: Icons.location_city_outlined,
          onTap: () => _closeAndNavigate(
            () => context.push('/manager-dashboard/add-site'),
          ),
        ),
      );
    }
    if (widget.showBuildingAction) {
      actions.add(
        _FabAction(
          label: t.newBuilding,
          icon: Icons.apartment_outlined,
          onTap: () => _closeAndNavigate(
            () => context.push('/manager-dashboard/add-building'),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();
    if (actions.length == 1) {
      final only = actions.first;
      return FloatingActionButton.extended(
        onPressed: only.onTap,
        backgroundColor: AppColors.actionButton,
        foregroundColor: AppColors.actionButtonForeground,
        icon: Icon(only.icon),
        label: Text(only.label),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < actions.length; i++)
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final isCompleted = _controller.isCompleted;
              final align = Align(
                alignment: Alignment.bottomCenter,
                heightFactor: _expandAnimation.value,
                child: child,
              );
              if (isCompleted) {
                return align;
              }
              return ClipRect(child: align);
            },
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
                child: _MiniFabAction(action: actions[i]),
              ),
            ),
          ),
        FloatingActionButton.extended(
          onPressed: _toggle,
          backgroundColor: AppColors.actionButton,
          foregroundColor: AppColors.actionButtonForeground,
          icon: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: _duration,
            curve: _curve,
            child: Icon(_open ? Icons.close : Icons.add),
          ),
          label: Text(
            _open ? context.t.common.close : context.t.common.kNew,
          ),
        ),
      ],
    );
  }
}

class _FabAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FabAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class _MiniFabAction extends StatelessWidget {
  final _FabAction action;

  const _MiniFabAction({required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.actionButton,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  action.icon,
                  color: AppColors.actionButtonForeground,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  action.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.actionButtonForeground,
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
