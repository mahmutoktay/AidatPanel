import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import 'premium_bottom_sheet.dart';

/// Tek seçimli alt picker seçeneği.
class PremiumFilterPickerOption<T> {
  final T value;
  final String label;
  final IconData icon;

  const PremiumFilterPickerOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

/// Premium filtre sheet alanları için tek seçimli alt sayfa.
Future<T?> showPremiumSingleSelectPicker<T>({
  required BuildContext context,
  required String title,
  required List<PremiumFilterPickerOption<T>> options,
  required T? selected,
  bool Function(T? a, T? b)? equals,
}) {
  final isSelected = equals ?? (a, b) => a == b;

  return PremiumBottomSheetScaffold.show<T>(
    context: context,
    builder: (sheetContext) => PremiumBottomSheetScaffold(
      title: title,
      scrollable: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) SizedBox(height: AppSizes.spacingXS),
            PremiumActionSheetTile(
              icon: options[i].icon,
              label: options[i].label,
              trailing: isSelected(selected, options[i].value)
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.statusGreen,
                      size: 22,
                    )
                  : null,
              onTap: () => Navigator.pop(sheetContext, options[i].value),
            ),
          ],
        ],
      ),
    ),
  );
}
