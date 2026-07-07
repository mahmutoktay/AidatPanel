import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/strings.g.dart';
import 'minimal_form_widgets.dart';
import 'premium_bottom_sheet.dart';

/// Arama destekli tek seçim listesi (il, ilçe, mahalle).
class LocationPickerSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelected;

  const LocationPickerSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<String> items,
    String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => LocationPickerSheet(
        title: title,
        items: items,
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  String _query = '';

  List<String> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items
        .where((s) => s.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return PremiumBottomSheetScaffold(
      title: widget.title,
      showCloseButton: true,
      onClose: () => Navigator.of(context).pop(),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingL),
            child: MinimalSearchField(
              hint: context.t.common.search,
              autofocus: widget.items.length > 8,
              whiteBackground: true,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacingL),
              child: Text(
                context.t.common.noResults,
                style: AppTypography.body1.copyWith(
                  color: AppColors.mutedText,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: AppSizes.spacingL),
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                final item = filtered[index];
                return PremiumActionSheetTile(
                  icon: Icons.location_on_outlined,
                  label: item,
                  iconColor: AppColors.statusBlue,
                  iconBackground: widget.selected == item
                      ? AppColors.statusBlue.withValues(alpha: 0.15)
                      : null,
                  trailing: widget.selected == item
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.statusGreen,
                          size: 22,
                        )
                      : null,
                  onTap: () {
                    widget.onSelected(item);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
