import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../data/buildings_store.dart';
import '../../domain/entities/collection_preset_entity.dart';
import '../utils/collection_preset_display.dart';

enum _IbanEntryMode { saved, manual }

/// M3 — Tahsilat IBAN: kayıtlı setten seç (sheet) veya yeni gir.
class BuildingCollectionFields extends ConsumerStatefulWidget {
  final TextEditingController ibanController;
  final TextEditingController accountTitleController;
  final TextEditingController referenceTemplateController;

  /// Ayarlar düzenleme: segment / kayıtlı liste gösterme.
  final bool manualOnly;

  const BuildingCollectionFields({
    super.key,
    required this.ibanController,
    required this.accountTitleController,
    required this.referenceTemplateController,
    this.manualOnly = false,
  });

  @override
  ConsumerState<BuildingCollectionFields> createState() =>
      _BuildingCollectionFieldsState();
}

class _BuildingCollectionFieldsState
    extends ConsumerState<BuildingCollectionFields> {
  _IbanEntryMode _mode = _IbanEntryMode.manual;
  String? _selectedPresetIban;
  bool _modeInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(collectionPresetsProvider);
      _syncModeFromExistingFields();
    });
  }

  void _syncModeFromExistingFields() {
    final iban = IbanUtils.normalize(widget.ibanController.text);
    if (iban.isNotEmpty) {
      _selectedPresetIban = iban;
    }
  }

  void _applyPreset(CollectionPresetEntity preset) {
    final iban = IbanUtils.normalize(preset.collectionIban);
    widget.ibanController.text = IbanUtils.formatDisplay(iban);
    widget.accountTitleController.text =
        preset.collectionAccountTitle ?? '';
    widget.referenceTemplateController.text =
        preset.paymentReferenceTemplate ?? '';
    setState(() => _selectedPresetIban = iban);
  }

  void _resetCollectionInput() {
    widget.ibanController.clear();
    widget.accountTitleController.clear();
    widget.referenceTemplateController.clear();
    _selectedPresetIban = null;
  }

  void _setMode(_IbanEntryMode mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _resetCollectionInput();
    });
  }

  Future<void> _openPresetPicker(List<CollectionPresetEntity> presets) async {
    final picked = await CollectionPresetPickerSheet.show(
      context,
      presets: presets,
      selectedIban: _selectedPresetIban,
    );
    if (picked != null && mounted) {
      _applyPreset(picked);
    }
  }

  String? _validateIban(String? value) {
    final t = context.t.features.buildings.collection;
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      final any = IbanUtils.hasAnyCollectionInput(
        iban: widget.ibanController.text,
        accountTitle: widget.accountTitleController.text,
        referenceTemplate: widget.referenceTemplateController.text,
      );
      if (any && !IbanUtils.isValidTrIban(widget.ibanController.text)) {
        return t.ibanRequiredIfOtherFilled;
      }
      return null;
    }
    if (!IbanUtils.isValidTrIban(raw)) return t.ibanInvalid;
    return null;
  }

  void _ensureDefaultMode(List<CollectionPresetEntity> presets) {
    if (_modeInitialized) return;
    _modeInitialized = true;
    if (presets.isEmpty) return;

    final current = IbanUtils.normalize(widget.ibanController.text);
    if (current.isNotEmpty) {
      final match = presets.any(
        (p) => IbanUtils.normalize(p.collectionIban) == current,
      );
      setState(() {
        _mode = match ? _IbanEntryMode.saved : _IbanEntryMode.manual;
        if (match) _selectedPresetIban = current;
      });
      return;
    }

    setState(() => _mode = _IbanEntryMode.saved);
  }

  CollectionPresetEntity? _findSelectedPreset(List<CollectionPresetEntity> presets) {
    if (_selectedPresetIban == null) return null;
    for (final p in presets) {
      if (IbanUtils.normalize(p.collectionIban) == _selectedPresetIban) {
        return p;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings.collection;
    final presetsAsync = ref.watch(collectionPresetsProvider);

    ref.listen(collectionPresetsProvider, (_, next) {
      next.whenData(_ensureDefaultMode);
    });

    if (widget.manualOnly) {
      return _ManualCollectionFields(
        ibanController: widget.ibanController,
        accountTitleController: widget.accountTitleController,
        referenceTemplateController: widget.referenceTemplateController,
        validateIban: _validateIban,
        onChanged: () {},
      );
    }

    final presets = presetsAsync.value ?? const <CollectionPresetEntity>[];
    final hasPresets = presets.isNotEmpty;
    final selectedPreset = _findSelectedPreset(presets);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.sectionHint,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.spacingM),
        if (hasPresets) ...[
          _IbanEntryModeToggle(
            mode: _mode,
            savedLabel: t.modeSaved,
            newLabel: t.modeNew,
            onSavedTap: () => _setMode(_IbanEntryMode.saved),
            onNewTap: () => _setMode(_IbanEntryMode.manual),
          ),
          const SizedBox(height: AppSizes.spacingM),
        ],
        if (_mode == _IbanEntryMode.saved && hasPresets)
          presetsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.spacingM),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
            error: (error, stackTrace) => Text(
              t.presetsLoadFailed,
              style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
            ),
            data: (_) {
              if (presets.isEmpty) {
                return Text(
                  t.presetsEmpty,
                  style:
                      AppTypography.body2.copyWith(color: AppColors.textSecondary),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (selectedPreset != null)
                    _SelectedPresetSummary(
                      preset: selectedPreset,
                      onTap: () => _openPresetPicker(presets),
                    )
                  else
                    _PickSavedIbanButton(
                      label: t.pickSavedIban,
                      onTap: () => _openPresetPicker(presets),
                    ),
                ],
              );
            },
          )
        else
          _ManualCollectionFields(
            ibanController: widget.ibanController,
            accountTitleController: widget.accountTitleController,
            referenceTemplateController: widget.referenceTemplateController,
            validateIban: _validateIban,
            onChanged: () => setState(() => _selectedPresetIban = null),
          ),
      ],
    );
  }
}

/// Kayıtlı IBAN listesi — ana formu uzatmaz; sheet içinde kaydırılır.
class CollectionPresetPickerSheet extends StatefulWidget {
  final List<CollectionPresetEntity> presets;
  final String? selectedIban;

  const CollectionPresetPickerSheet({
    super.key,
    required this.presets,
    this.selectedIban,
  });

  static Future<CollectionPresetEntity?> show(
    BuildContext context, {
    required List<CollectionPresetEntity> presets,
    String? selectedIban,
  }) {
    return showModalBottomSheet<CollectionPresetEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: AppButtonStyles.sheetTop,
      builder: (_) => CollectionPresetPickerSheet(
        presets: presets,
        selectedIban: selectedIban,
      ),
    );
  }

  @override
  State<CollectionPresetPickerSheet> createState() =>
      _CollectionPresetPickerSheetState();
}

class _CollectionPresetPickerSheetState
    extends State<CollectionPresetPickerSheet> {
  String _query = '';

  List<CollectionPresetEntity> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.presets;
    return widget.presets.where((p) {
      final iban = IbanUtils.formatDisplay(p.collectionIban).toLowerCase();
      final title = (p.collectionAccountTitle ?? '').toLowerCase();
      return iban.contains(q) || title.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings.collection;
    final filtered = _filtered;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingL),
            child: Text(
              t.savedListTitle,
              style: AppTypography.h3,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingL),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: AppTypography.body1,
              decoration: InputDecoration(
                hintText: t.searchSavedIban,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingM,
                  vertical: AppSizes.spacingS,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      t.presetsEmpty,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.spacingL,
                      0,
                      AppSizes.spacingL,
                      AppSizes.spacingL,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSizes.spacingS),
                    itemBuilder: (_, i) {
                      final p = filtered[i];
                      final ibanNorm = IbanUtils.normalize(p.collectionIban);
                      final selected = widget.selectedIban == ibanNorm;
                      return _PresetSelectTile(
                        preset: p,
                        selected: selected,
                        onTap: () => Navigator.of(context).pop(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PickSavedIbanButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PickSavedIbanButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _PresetRowLeadingIcon(
                icon: Icons.account_balance_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body1.copyWith(color: AppColors.primary),
                ),
              ),
              const _PresetRowTrailingChevron(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedPresetSummary extends StatelessWidget {
  final CollectionPresetEntity preset;
  final VoidCallback onTap;

  const _SelectedPresetSummary({
    required this.preset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings.collection;
    final detailStyle = AppTypography.caption.copyWith(
      color: AppColors.textSecondary,
      height: 1.35,
    );

    final details = CollectionPresetDisplay.detailLines(context, preset);

    return Semantics(
      button: true,
      label: '${t.changeSavedIban}. ${IbanUtils.formatDisplay(preset.collectionIban)}',
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            padding: const EdgeInsets.all(AppSizes.spacingM),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _PresetRowLeadingIcon(
                  icon: Icons.check_circle,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          IbanUtils.formatDisplay(preset.collectionIban),
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      ...details.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(line, style: detailStyle),
                        ),
                      ),
                    ],
                  ),
                ),
                const _PresetRowTrailingChevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetSelectTile extends StatelessWidget {
  final CollectionPresetEntity preset;
  final bool selected;
  final VoidCallback onTap;

  const _PresetSelectTile({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final detailLines = CollectionPresetDisplay.detailLines(context, preset);
    final detailStyle = AppTypography.caption.copyWith(
      color: AppColors.textSecondary,
      height: 1.35,
    );

    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: AppSizes.spacingS,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _PresetRowLeadingIcon(
                icon: selected
                    ? Icons.check_circle
                    : Icons.account_balance_outlined,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      IbanUtils.formatDisplay(preset.collectionIban),
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (detailLines.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...detailLines.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            line,
                            style: detailStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kayıtlı / Yeni IBAN — bina oluştur butonu ile aynı köşe yarıçapı (12dp).
class _IbanEntryModeToggle extends StatelessWidget {
  final _IbanEntryMode mode;
  final String savedLabel;
  final String newLabel;
  final VoidCallback onSavedTap;
  final VoidCallback onNewTap;

  const _IbanEntryModeToggle({
    required this.mode,
    required this.savedLabel,
    required this.newLabel,
    required this.onSavedTap,
    required this.onNewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _IbanModeOptionButton(
            label: savedLabel,
            icon: Icons.history,
            selected: mode == _IbanEntryMode.saved,
            onTap: onSavedTap,
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: _IbanModeOptionButton(
            label: newLabel,
            icon: Icons.add_card_outlined,
            selected: mode == _IbanEntryMode.manual,
            onTap: onNewTap,
          ),
        ),
      ],
    );
  }
}

class _IbanModeOptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _IbanModeOptionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return SizedBox(
        height: AppSizes.minTouchTarget,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          label: Text(label, style: AppTypography.label),
          style: AppButtonStyles.elevatedPrimary(),
        ),
      );
    }

    return SizedBox(
      height: AppSizes.minTouchTarget,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: AppColors.textPrimary),
        label: Text(
          label,
          style: AppTypography.label.copyWith(color: AppColors.textPrimary),
        ),
        style: AppButtonStyles.outlinedNeutral(),
      ),
    );
  }
}

/// Kayıtlı IBAN kartları — dar yan ikon yuvası.
class _PresetRowLeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _PresetRowLeadingIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.listRowIconWidth,
      child: Icon(icon, color: color, size: AppSizes.listRowIconSize),
    );
  }
}

class _PresetRowTrailingChevron extends StatelessWidget {
  const _PresetRowTrailingChevron();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: AppSizes.listRowActionWidth,
      child: Icon(
        Icons.chevron_right,
        color: AppColors.primary,
        size: AppSizes.listRowIconSize,
      ),
    );
  }
}

class _ManualCollectionFields extends StatelessWidget {
  final TextEditingController ibanController;
  final TextEditingController accountTitleController;
  final TextEditingController referenceTemplateController;
  final String? Function(String?) validateIban;
  final VoidCallback onChanged;

  const _ManualCollectionFields({
    required this.ibanController,
    required this.accountTitleController,
    required this.referenceTemplateController,
    required this.validateIban,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings.collection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: ibanController,
          decoration: InputDecoration(
            labelText: t.ibanLabel,
            hintText: t.ibanHint,
            prefixIcon: const Icon(Icons.account_balance_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: AppTypography.body1,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s]')),
            LengthLimitingTextInputFormatter(34),
          ],
          validator: validateIban,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: AppSizes.spacingM),
        TextFormField(
          controller: accountTitleController,
          decoration: InputDecoration(
            labelText: t.accountTitleLabel,
            hintText: t.accountTitleHint,
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: AppTypography.body1,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: AppSizes.spacingM),
        TextFormField(
          controller: referenceTemplateController,
          decoration: InputDecoration(
            labelText: t.referenceTemplateLabel,
            hintText: t.referenceTemplateHint,
            prefixIcon: const Icon(Icons.notes_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: AppTypography.body1,
          maxLines: 2,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

/// Form submit için normalize edilmiş tahsilat alanları (hepsi boş → null).
class BuildingCollectionInput {
  final String? collectionIban;
  final String? collectionAccountTitle;
  final String? paymentReferenceTemplate;

  const BuildingCollectionInput({
    this.collectionIban,
    this.collectionAccountTitle,
    this.paymentReferenceTemplate,
  });

  static BuildingCollectionInput? fromControllers({
    required TextEditingController iban,
    required TextEditingController accountTitle,
    required TextEditingController referenceTemplate,
  }) {
    final ibanNorm = IbanUtils.normalize(iban.text);
    final title = accountTitle.text.trim();
    final template = referenceTemplate.text.trim();

    if (!IbanUtils.hasAnyCollectionInput(
      iban: ibanNorm,
      accountTitle: title,
      referenceTemplate: template,
    )) {
      return null;
    }

    return BuildingCollectionInput(
      collectionIban: ibanNorm.isEmpty ? null : ibanNorm,
      collectionAccountTitle: title.isEmpty ? null : title,
      paymentReferenceTemplate: template.isEmpty ? null : template,
    );
  }
}
