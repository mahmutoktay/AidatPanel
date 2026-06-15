import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../data/buildings_store.dart';
import '../../domain/entities/collection_preset_entity.dart';
import '../utils/collection_preset_display.dart';

enum _IbanEntryMode { saved, manual }

/// Sheet seçim sonucu.
class CollectionPresetPickResult {
  final CollectionPresetEntity? preset;
  final bool addNew;

  const CollectionPresetPickResult._({this.preset, this.addNew = false});

  const CollectionPresetPickResult.preset(CollectionPresetEntity value)
      : this._(preset: value);

  const CollectionPresetPickResult.addNew() : this._(addNew: true);
}

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
    final result = await CollectionPresetPickerSheet.show(
      context,
      presets: presets,
      selectedIban: _selectedPresetIban,
    );
    if (!mounted || result == null) return;
    if (result.addNew) {
      _setMode(_IbanEntryMode.manual);
      return;
    }
    if (result.preset != null) {
      _applyPreset(result.preset!);
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
        if (!widget.manualOnly) ...[
          MinimalSectionLabel(
            title: t.sectionTitle,
            subtitle: t.sectionHint,
          ),
          if (hasPresets) ...[
            const SizedBox(height: AppSizes.spacingM),
            CollectionIbanSegmentToggle(
              savedSelected: _mode == _IbanEntryMode.saved,
              savedLabel: t.modeSaved,
              newLabel: t.modeNew,
              onSavedTap: () => _setMode(_IbanEntryMode.saved),
              onNewTap: () => _setMode(_IbanEntryMode.manual),
            ),
          ],
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
              style: ProfileSettingsUi.handle,
            ),
            data: (_) {
              if (presets.isEmpty) {
                return Text(
                  t.presetsEmpty,
                  style: ProfileSettingsUi.handle,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MinimalPickerField(
                    label: t.pickSavedIban,
                    value: selectedPreset != null
                        ? IbanUtils.formatDisplay(selectedPreset.collectionIban)
                        : null,
                    hint: t.pickSavedIban,
                    icon: Icons.account_balance_outlined,
                    onTap: () => _openPresetPicker(presets),
                  ),
                  if (selectedPreset != null) ...[
                    const SizedBox(height: AppSizes.spacingXS),
                    _SelectedPresetCompactSummary(preset: selectedPreset),
                  ],
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

class _SelectedPresetCompactSummary extends StatelessWidget {
  final CollectionPresetEntity preset;

  const _SelectedPresetCompactSummary({required this.preset});

  @override
  Widget build(BuildContext context) {
    final accountTitle = preset.collectionAccountTitle?.trim();

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            IbanUtils.formatDisplay(preset.collectionIban),
            style: ProfileSettingsUi.handle.copyWith(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (accountTitle != null && accountTitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              accountTitle,
              style: ProfileSettingsUi.handle.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
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

  static Future<CollectionPresetPickResult?> show(
    BuildContext context, {
    required List<CollectionPresetEntity> presets,
    String? selectedIban,
  }) {
    return showModalBottomSheet<CollectionPresetPickResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.dashboardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Column(
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
                AppSizes.spacingM,
                AppSizes.spacingM,
                AppSizes.spacingM,
                AppSizes.spacingS,
              ),
              child: Text(t.savedListTitle, style: ProfileSettingsUi.title),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
              child: MinimalSearchField(
                hint: t.searchSavedIban,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
              child: Text(
                t.savedListSectionLabel.toUpperCase(),
                style: ProfileSettingsUi.fieldLabelUppercase,
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        t.presetsEmpty,
                        style: ProfileSettingsUi.handle,
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.spacingM,
                        0,
                        AppSizes.spacingM,
                        AppSizes.spacingS,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSizes.spacingS),
                      itemBuilder: (_, i) {
                        final p = filtered[i];
                        final ibanNorm = IbanUtils.normalize(p.collectionIban);
                        final selected = widget.selectedIban == ibanNorm;
                        return _PresetSelectTile(
                          preset: p,
                          selected: selected,
                          onTap: () => Navigator.of(context).pop(
                            CollectionPresetPickResult.preset(p),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.spacingM,
                AppSizes.spacingS,
                AppSizes.spacingM,
                AppSizes.spacingM + MediaQuery.paddingOf(context).bottom,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(
                    const CollectionPresetPickResult.addNew(),
                  ),
                  borderRadius:
                      BorderRadius.circular(ProfileSettingsUi.fieldRadius),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: AppSizes.minTouchTarget,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        ProfileSettingsUi.fieldRadius,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _DashedBorderPainter(
                        color: ProfileSettingsUi.muted.withValues(alpha: 0.5),
                        radius: ProfileSettingsUi.fieldRadius,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 20,
                            color: ProfileSettingsUi.muted,
                          ),
                          const SizedBox(width: AppSizes.spacingXS),
                          Text(
                            t.savedIbansAddTitle,
                            style: ProfileSettingsUi.fieldValue.copyWith(
                              color: ProfileSettingsUi.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0.0, metric.length)),
          paint,
        );
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
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
    final t = context.t.features.buildings.collection;
    final detailRows = CollectionPresetDisplay.inlineDetailRows(context, preset);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          padding: const EdgeInsets.all(AppSizes.spacingM),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
            border: selected
                ? Border.all(
                    color: ProfileSettingsUi.ink,
                    width: ProfileSettingsUi.fieldFocusBorderWidth,
                  )
                : null,
            boxShadow: selected ? null : DashboardScreenStyle.subtleShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: ProfileSettingsUi.fieldIconSize,
                color: ProfileSettingsUi.muted,
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      IbanUtils.formatDisplay(preset.collectionIban),
                      style: ProfileSettingsUi.fieldValue.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    for (final row in detailRows) ...[
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: ProfileSettingsUi.handle.copyWith(fontSize: 13),
                          children: [
                            TextSpan(text: '${row.label} '),
                            TextSpan(
                              text: row.value,
                              style: ProfileSettingsUi.fieldValue.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (preset.buildingCount > 1) ...[
                      const SizedBox(height: AppSizes.spacingXS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusGreenBg,
                          borderRadius: BorderRadius.circular(
                            ProfileSettingsUi.radiusPill,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: AppColors.statusGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              t.detailUsedInBuildings.replaceAll(
                                '{count}',
                                '${preset.buildingCount}',
                              ),
                              style: ProfileSettingsUi.fieldLabel.copyWith(
                                color: AppColors.statusGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
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
        MinimalTextField(
          controller: ibanController,
          label: t.ibanLabel,
          hint: t.ibanHint,
          icon: Icons.account_balance_outlined,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s]')),
            LengthLimitingTextInputFormatter(34),
          ],
          validator: validateIban,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: AppSizes.spacingFieldSpacing),
        MinimalTextField(
          controller: accountTitleController,
          label: t.accountTitleLabel,
          hint: t.accountTitleHint,
          icon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: AppSizes.spacingFieldSpacing),
        MinimalTextField(
          controller: referenceTemplateController,
          label: t.referenceTemplateLabel,
          hint: t.referenceTemplateHint,
          icon: Icons.format_list_bulleted,
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
