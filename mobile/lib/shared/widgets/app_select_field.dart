import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

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
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
      final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.55;
      final listHeight = (options.length * AppSizes.listItemHeightSmall)
          .clamp(0.0, maxHeight - 120)
          .toDouble();

      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSizes.spacingS),
              const _SelectSheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spacingL,
                  AppSizes.spacingM,
                  AppSizes.spacingL,
                  AppSizes.spacingS,
                ),
                child: Text(
                  title,
                  style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: listHeight),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingM,
                  ),
                  itemCount: options.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spacingXS),
                  itemBuilder: (_, index) {
                    final opt = options[index];
                    final isSelected = opt.value == selected;
                    return _SelectSheetOption(
                      label: opt.label,
                      isSelected: isSelected,
                      onTap: () {
                        onSelected(opt.value);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
            ],
          ),
        ),
      );
    },
  );
}

class _SelectSheetHandle extends StatelessWidget {
  const _SelectSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SelectSheetOption extends StatelessWidget {
  const _SelectSheetOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(minHeight: AppSizes.listItemHeightSmall),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: AppSizes.spacingS,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.fill.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.borderColor.withValues(alpha: 0.12),
              width: isSelected ? 1 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body1.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
