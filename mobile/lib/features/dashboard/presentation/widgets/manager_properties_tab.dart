import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../sites/presentation/widgets/buildings_expandable_fab.dart';
import '../../../sites/presentation/widgets/manager_sites_tab.dart';
import '../widgets/manager_buildings_tab.dart';

/// Siteler | Binalar alt sekmeleri + genişleyen FAB.
class ManagerPropertiesTab extends ConsumerStatefulWidget {
  final AsyncValue<List<BuildingEntity>> standaloneBuildingsAsync;

  const ManagerPropertiesTab({
    super.key,
    required this.standaloneBuildingsAsync,
  });

  @override
  ConsumerState<ManagerPropertiesTab> createState() =>
      _ManagerPropertiesTabState();
}

class _ManagerPropertiesTabState extends ConsumerState<ManagerPropertiesTab>
    with SingleTickerProviderStateMixin {
  late final TabController _innerTabController;

  @override
  void initState() {
    super.initState();
    _innerTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _innerTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: AppSizes.screenBodyScrollPadding.copyWith(
                top: 0,
                bottom: AppSizes.spacingS,
              ),
              child: TabBar(
                controller: _innerTabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.mutedText,
                indicatorColor: AppColors.primary,
                labelStyle: AppTypography.button.copyWith(fontSize: 16),
                unselectedLabelStyle:
                    AppTypography.body1.copyWith(fontSize: 16),
                tabs: [
                  Tab(text: t.tabSites),
                  Tab(text: t.tabBuildings),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _innerTabController,
                children: [
                  const ManagerSitesTab(),
                  ManagerBuildingsTab(
                    buildingsAsync: widget.standaloneBuildingsAsync,
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: AppSizes.spacingL,
          bottom: AppSizes.spacingL,
          child: const BuildingsExpandableFab(),
        ),
      ],
    );
  }
}
