import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import 'premium_bottom_sheet.dart';

/// Tek seçim alanı — Material dropdown yerine alt sayfa listesi.
class AppSelectOption<T> {
  const AppSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Etiket + değer satırı; dokununca minimal seçim alt sayfası açılır.
class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
    this.sheetTitle,
    this.displayText,
  });

  final String label;
  final T? value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final String? sheetTitle;

  /// Seçili değerin alanda gösterilecek metni (yoksa eşleşen option.label).
  final String Function(T? value)? displayText;

  String _resolveDisplayText() {
    if (displayText != null) return displayText!(value);
    if (value == null) return '';
    for (final opt in options) {
      if (opt.value == value) return opt.label;
    }
    return '';
  }

  void _openSheet(BuildContext context) {
    if (!enabled || onChanged == null) return;
    showAppSelectSheet<T>(
      context: context,
      title: sheetTitle ?? label,
      options: options,
      selected: value,
      onSelected: onChanged!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = _resolveDisplayText();
    final canTap = enabled && onChanged != null;

    return Semantics(
      button: canTap,
      label: label,
      value: text,
      enabled: canTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? () => _openSheet(context) : null,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.minTouchTargetComfort),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: AppSizes.spacingS,
            ),
            decoration: BoxDecoration(
              color: enabled ? AppColors.fill : AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.14),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: AppTypography.caption.copyWith(
                          color: enabled
                              ? AppColors.textSecondary
                              : AppColors.textDisabled,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        text,
                        style: AppTypography.body1.copyWith(
                          color: enabled
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: enabled ? AppColors.textSecondary : AppColors.textDisabled,
                  size: AppSizes.iconSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Seçenek listesi alt sayfası (dropdown overlay yerine).
Future<void> showAppSelectSheet<T>({
  required BuildContext context,
  required String title,
  required List<AppSelectOption<T>> options,
  required T? selected,
  required ValueChanged<T?> onSelected,
}) {
  return PremiumBottomSheetScaffold.show<void>(
    context: context,
    builder: (sheetContext) => PremiumBottomSheetScaffold(
      title: title,
      scrollable: true,
      body: PremiumActionSheetList(
        children: [
          for (var i = 0; i < options.length; i++)
            Builder(
              builder: (_) {
                final opt = options[i];
                final isSelected = opt.value == selected;
                return PremiumActionSheetTile(
                  icon: Icons.radio_button_unchecked_outlined,
                  label: opt.label,
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                      : null,
                  onTap: () {
                    onSelected(opt.value);
                    Navigator.pop(sheetContext);
                  },
                );
              },
            ),
        ],
      ),
    ),
  );
}
