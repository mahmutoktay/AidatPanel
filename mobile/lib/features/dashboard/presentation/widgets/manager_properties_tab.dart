import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../widgets/manager_buildings_tab.dart';
import '../../../sites/presentation/widgets/manager_sites_tab.dart';

enum PropertiesSegment { sites, buildings }

class ManagerPropertiesTab extends ConsumerStatefulWidget {
  const ManagerPropertiesTab({super.key});

  @override
  ConsumerState<ManagerPropertiesTab> createState() =>
      _ManagerPropertiesTabState();
}

class _ManagerPropertiesTabState extends ConsumerState<ManagerPropertiesTab> {
  PropertiesSegment _segment = PropertiesSegment.sites;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: AppSizes.screenBodyScrollPadding.copyWith(bottom: 0),
          child: SegmentedButton<PropertiesSegment>(
            segments: [
              ButtonSegment(
                value: PropertiesSegment.sites,
                label: Text(t.tabSites),
                icon: const Icon(Icons.domain_outlined),
              ),
              ButtonSegment(
                value: PropertiesSegment.buildings,
                label: Text(t.tabBuildings),
                icon: const Icon(Icons.apartment_outlined),
              ),
            ],
            selected: {_segment},
            onSelectionChanged: (value) {
              setState(() => _segment = value.first);
            },
            style: ButtonStyle(
              textStyle: WidgetStatePropertyAll(
                AppTypography.button.copyWith(fontWeight: FontWeight.w700),
              ),
              minimumSize: const WidgetStatePropertyAll(
                Size(0, AppSizes.minTouchTarget),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: _segment == PropertiesSegment.sites
                ? const ManagerSitesTab(key: ValueKey('sites_tab'))
                : const ManagerBuildingsTab(
                    key: ValueKey('buildings_tab'),
                  ),
          ),
        ),
      ],
    );
  }
}
