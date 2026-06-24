import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/utils/turkish_string_utils.dart';
import '../../features/buildings/data/turkish_locations.dart';
import '../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../l10n/strings.g.dart';
import 'minimal_form_widgets.dart';

/// Şehir / ilçe seçimi — DraggableScrollableSheet (donma yapmaz).
class SearchableLocationPicker extends StatefulWidget {
  const SearchableLocationPicker({
    super.key,
    required this.title,
    required this.items,
    required this.onSelected,
    this.selected,
    this.isCityList = false,
  });

  final String title;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelected;
  final bool isCityList;

  static Future<void> showCityPicker(
    BuildContext context, {
    required String? selected,
    required ValueChanged<String> onSelected,
  }) async {
    await TurkishLocations.ensureLoaded();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SearchableLocationPicker(
        title: context.t.common.selectCityTitle,
        items: TurkishLocations.sortedCityNames,
        selected: selected,
        onSelected: onSelected,
        isCityList: true,
      ),
    );
  }

  static Future<void> showDistrictPicker(
    BuildContext context, {
    required String city,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) async {
    await TurkishLocations.ensureLoaded();
    if (!context.mounted) return;
    final districts = TurkishLocations.districtsOf(city);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SearchableLocationPicker(
        title: context.t.common.selectDistrictTitle,
        items: districts,
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<SearchableLocationPicker> createState() =>
      _SearchableLocationPickerState();
}

class _SearchableLocationPickerState extends State<SearchableLocationPicker> {
  String _query = '';
  late List<String> _sortedItems;

  @override
  void initState() {
    super.initState();
    _sortedItems = sortTurkishList(widget.items);
  }

  @override
  void didUpdateWidget(SearchableLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _sortedItems = sortTurkishList(widget.items);
    }
  }

  List<String> get _filtered {
    if (_query.trim().isEmpty) return _sortedItems;
    if (widget.isCityList) {
      return TurkishLocations.filterCities(_query);
    }
    return filterTurkishSearch(_sortedItems, _query);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Material(
        color: AppColors.sheetBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.spacingS),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lineLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.dashboardScreenPaddingHorizontal,
                AppSizes.spacingM,
                AppSizes.dashboardScreenPaddingHorizontal,
                AppSizes.spacingS,
              ),
              child: Text(widget.title, style: ProfileSettingsUi.title),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.dashboardScreenPaddingHorizontal,
              ),
              child: MinimalSearchField(
                hint: context.t.common.search,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        context.t.common.noResults,
                        style: ProfileSettingsUi.handle,
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.dashboardScreenPaddingHorizontal,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, index) {
                        final item = filtered[index];
                        final isSelected = item == widget.selected;
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.spacingXS,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                widget.onSelected(item);
                                context.pop();
                              },
                              borderRadius: BorderRadius.circular(
                                ProfileSettingsUi.fieldRadius,
                              ),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: AppSizes.minTouchTarget,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.spacingM,
                                  vertical: AppSizes.spacingS,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? ProfileSettingsUi.background
                                      : ProfileSettingsUi.fieldFill,
                                  borderRadius: BorderRadius.circular(
                                    ProfileSettingsUi.fieldRadius,
                                  ),
                                  border: isSelected
                                      ? Border.all(
                                          color: ProfileSettingsUi.ink,
                                          width: ProfileSettingsUi
                                              .fieldFocusBorderWidth,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: ProfileSettingsUi.fieldValue
                                            .copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_rounded,
                                        color: AppColors.statusGreen,
                                        size: 22,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
