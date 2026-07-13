import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../l10n/strings.g.dart';
import 'minimal_form_widgets.dart';

/// Hızlı sayı seçimi için grid (1..maxQuickPick + "Daha Fazla").
class NumberGridSelector extends StatefulWidget {
  final int min;
  final int maxQuickPick;
  final int gridColumns;
  final int? selected;
  final int manualMax;
  final ValueChanged<int> onQuickPick;
  final ValueChanged<int> onManualConfirm;

  const NumberGridSelector({
    super.key,
    required this.min,
    required this.maxQuickPick,
    required this.gridColumns,
    required this.manualMax,
    required this.onQuickPick,
    required this.onManualConfirm,
    this.selected,
  });

  @override
  State<NumberGridSelector> createState() => _NumberGridSelectorState();
}

class _NumberGridSelectorState extends State<NumberGridSelector> {
  bool _showManual = false;
  final _manualController = TextEditingController();
  String? _manualError;

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _onMoreTap() {
    setState(() {
      _showManual = true;
      _manualError = null;
      final selected = widget.selected;
      _manualController.text = selected != null &&
              (selected > widget.maxQuickPick || selected < widget.min)
          ? '$selected'
          : '';
    });
  }

  void _confirmManual() {
    final raw = _manualController.text.trim();
    final value = int.tryParse(raw);
    if (value == null || value < widget.min || value > widget.manualMax) {
      setState(() {
        _manualError = context.t.common.wizardNumberRangeError.replaceAll(
          '{min}',
          '${widget.min}',
        ).replaceAll('{max}', '${widget.manualMax}');
      });
      return;
    }
    widget.onManualConfirm(value);
  }

  @override
  Widget build(BuildContext context) {
    if (_showManual) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MinimalTextField(
            controller: _manualController,
            label: context.t.common.wizardEnterNumber,
            hint: '${widget.min}–${widget.manualMax}',
            icon: Icons.tag_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            validator: (_) => _manualError,
          ),
          if (_manualError != null) ...[
            const SizedBox(height: AppSizes.spacingXS),
            Text(
              _manualError!,
              style: AppTypography.caption.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.spacingM),
          SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: FilledButton(
              onPressed: _confirmManual,
              child: Text(context.t.common.confirm),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _showManual = false),
            child: Text(context.t.common.wizardBackToGrid),
          ),
        ],
      );
    }

    final quickCount = widget.maxQuickPick - widget.min + 1;
    final itemCount = quickCount + 1;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridColumns,
        mainAxisSpacing: AppSizes.spacingS,
        crossAxisSpacing: AppSizes.spacingS,
        childAspectRatio: 1.15,
      ),
      itemCount: itemCount,
      itemBuilder: (_, index) {
        final isMore = index == quickCount;
        if (isMore) {
          final selected = widget.selected;
          final moreSelected = selected != null &&
              (selected > widget.maxQuickPick || selected < widget.min);
          return _GridCell(
            label: context.t.common.wizardMore,
            selected: moreSelected,
            onTap: _onMoreTap,
            isMore: true,
          );
        }
        final value = widget.min + index;
        return _GridCell(
          label: '$value',
          selected: widget.selected == value,
          onTap: () => widget.onQuickPick(value),
        );
      },
    );
  }
}

class _GridCell extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isMore;

  const _GridCell({
    required this.label,
    required this.selected,
    required this.onTap,
    this.isMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? AppColors.brand.withValues(alpha: 0.12)
                : ProfileSettingsUi.fieldFill,
            borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
            border: Border.all(
              color: selected
                  ? AppColors.brand
                  : AppColors.borderColor.withValues(alpha: 0.35),
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: ProfileSettingsUi.fieldValue.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: isMore ? 15 : 18,
                color: selected ? AppColors.brand : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
