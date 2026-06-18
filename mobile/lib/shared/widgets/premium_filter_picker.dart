import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
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
      body: PremiumActionSheetList(
        children: [
          for (final option in options)
            PremiumActionSheetTile(
              icon: option.icon,
              label: option.label,
              trailing: isSelected(selected, option.value)
                  ? Icon(
                      Icons.check_rounded,
                      color: AppColors.inkDark,
                    )
                  : null,
              onTap: () => Navigator.pop(sheetContext, option.value),
            ),
        ],
      ),
    ),
  );
}
