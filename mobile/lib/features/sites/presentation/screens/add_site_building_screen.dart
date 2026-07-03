import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

<<<<<<< HEAD
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/show_due_day_picker.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../buildings/data/buildings_store.dart';
=======
import '../../../../core/theme/app_sizes.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/show_due_day_picker.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../shared/widgets/toast_overlay.dart';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
import '../../../buildings/presentation/widgets/building_collection_fields.dart';
import '../../data/sites_store.dart';

const int _kFloorsMin = 1;
const int _kFloorsMax = 200;
const int _kApartmentsPerFloorMin = 1;
const int _kApartmentsPerFloorMax = 50;

class AddSiteBuildingScreen extends ConsumerStatefulWidget {
<<<<<<< HEAD
  const AddSiteBuildingScreen({super.key, required this.siteId});

  final String siteId;

=======
  final String siteId;

  const AddSiteBuildingScreen({super.key, required this.siteId});

>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  @override
  ConsumerState<AddSiteBuildingScreen> createState() =>
      _AddSiteBuildingScreenState();
}

class _AddSiteBuildingScreenState extends ConsumerState<AddSiteBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
<<<<<<< HEAD
  final _nameController = TextEditingController();
  final _blockLabelController = TextEditingController();
=======
  final _blockLabelController = TextEditingController();
  final _nameController = TextEditingController();
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  final _addressExtraController = TextEditingController();
  final _floorsController = TextEditingController();
  final _apartmentsPerFloorController = TextEditingController();
  final _monthlyDuesController = TextEditingController();
  final _collectionIbanController = TextEditingController();
  final _collectionAccountTitleController = TextEditingController();
  final _collectionReferenceTemplateController = TextEditingController();

<<<<<<< HEAD
  bool _overrideDues = false;
=======
  bool _overrideDue = false;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  bool _overrideCollection = false;
  int _selectedDueDay = 1;
  bool _pickingDueDay = false;
  bool _submitting = false;

  @override
  void dispose() {
<<<<<<< HEAD
    _nameController.dispose();
    _blockLabelController.dispose();
=======
    _blockLabelController.dispose();
    _nameController.dispose();
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    _addressExtraController.dispose();
    _floorsController.dispose();
    _apartmentsPerFloorController.dispose();
    _monthlyDuesController.dispose();
    _collectionIbanController.dispose();
    _collectionAccountTitleController.dispose();
    _collectionReferenceTemplateController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _pickDueDay() async {
    if (_pickingDueDay) return;
    setState(() => _pickingDueDay = true);
    final picked = await showDueDayPicker(context, selectedDueDay: _selectedDueDay);
    if (mounted) {
      setState(() {
        _pickingDueDay = false;
        if (picked != null) _selectedDueDay = picked;
      });
    }
  }

=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final siteAsync = ref.watch(siteDetailProvider(widget.siteId));
<<<<<<< HEAD
    final site = siteAsync.value;

    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        appBar: AppBar(
          title: Text(t.addBlock, style: ProfileSettingsUi.title),
        ),
        bottomNavigationBar: MinimalStickyActionBar(
          label: t.addBlock,
          loading: _submitting,
          onPressed: _onSubmit,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: AppSizes.screenBodyScrollPadding,
              children: [
                MinimalTextField(
                  controller: _nameController,
                  label: context.t.common.buildingName,
                  hint: context.t.common.buildingNameHint,
                  icon: Icons.apartment_outlined,
                  required: true,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.t.common.fieldRequired
                      : null,
                ),
                const SizedBox(height: AppSizes.spacingFieldSpacing),
                MinimalTextField(
                  controller: _blockLabelController,
                  label: t.blockLabel,
                  hint: t.blockLabelHint,
                  icon: Icons.label_outline,
                ),
                const SizedBox(height: AppSizes.spacingFieldSpacing),
                MinimalTextField(
                  controller: _addressExtraController,
                  label: context.t.common.streetAddress,
                  hint: context.t.common.streetAddressHint,
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: AppSizes.spacingFieldSpacing),
                Row(
                  children: [
                    Expanded(
                      child: MinimalTextField(
                        controller: _floorsController,
                        label: context.t.common.floorCount,
                        hint: context.t.common.floorCountHint,
                        icon: Icons.apartment_outlined,
=======

    return DashboardSecondaryScaffold(
      title: t.addBlockTitle,
      canPop: !_submitting,
      useMinimalBackButton: true,
      onBack: _submitting ? null : () => context.pop(),
      bottomNavigationBar: MinimalStickyActionBar(
        label: t.createBlock,
        loading: _submitting,
        onPressed: _onSubmit,
      ),
      body: siteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(userFacingError(e))),
        data: (detail) {
          return SafeArea(
            child: AbsorbPointer(
              absorbing: _submitting,
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppSizes.screenBodyScrollPadding.copyWith(
                    top: AppSizes.spacingS,
                    bottom: AppSizes.spacingXL,
                  ),
                  children: [
                    MinimalSectionLabel(
                      title: t.blockSection,
                      subtitle: detail.site.name,
                    ),
                    const SizedBox(height: AppSizes.spacingS),
                    MinimalTextField(
                      controller: _blockLabelController,
                      label: t.blockLabel,
                      hint: t.blockLabelHint,
                      icon: Icons.view_module_outlined,
                      required: true,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? context.t.common.fieldRequired
                          : null,
                    ),
                    const SizedBox(height: AppSizes.spacingFieldSpacing),
                    MinimalTextField(
                      controller: _nameController,
                      label: t.blockNameOptional,
                      hint: t.blockNameHint,
                      icon: Icons.apartment_outlined,
                    ),
                    const SizedBox(height: AppSizes.spacingFieldSpacing),
                    MinimalTextField(
                      controller: _addressExtraController,
                      label: t.addressExtra,
                      hint: t.addressExtraHint,
                      icon: Icons.place_outlined,
                    ),
                    const SizedBox(height: AppSizes.spacingFieldSpacing),
                    MinimalSectionLabel(title: context.t.common.details),
                    const SizedBox(height: AppSizes.spacingS),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: MinimalTextField(
                              controller: _floorsController,
                              label: context.t.common.floorCount,
                              hint: context.t.common.floorCountHint,
                              icon: Icons.apartment_outlined,
                              required: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) => _validateRange(
                                v,
                                min: _kFloorsMin,
                                max: _kFloorsMax,
                                rangeError:
                                    context.t.common.floorRangeError,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingS),
                          Expanded(
                            child: MinimalTextField(
                              controller: _apartmentsPerFloorController,
                              label: context.t.common.apartmentsPerFloor,
                              hint: context.t.common.apartmentsPerFloorHint,
                              icon: Icons.door_front_door_outlined,
                              required: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) => _validateRange(
                                v,
                                min: _kApartmentsPerFloorMin,
                                max: _kApartmentsPerFloorMax,
                                rangeError: context
                                    .t.common.apartmentsPerFloorRangeError,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingFieldSpacing),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        t.overrideDue,
                        style: ProfileSettingsUi.fieldValue,
                      ),
                      subtitle: Text(
                        t.overrideDueHint,
                        style: ProfileSettingsUi.handle,
                      ),
                      value: _overrideDue,
                      onChanged: (v) => setState(() => _overrideDue = v),
                    ),
                    if (_overrideDue) ...[
                      MinimalTextField(
                        controller: _monthlyDuesController,
                        label: context.t.common.monthlyDuesLabel,
                        hint: context.t.common.monthlyDuesHint,
                        icon: Icons.payments_outlined,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
<<<<<<< HEAD
                        required: true,
                        validator: (v) => _validateRange(
                          v,
                          min: _kFloorsMin,
                          max: _kFloorsMax,
                          rangeError: context.t.common.floorRangeError,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    Expanded(
                      child: MinimalTextField(
                        controller: _apartmentsPerFloorController,
                        label: context.t.common.apartmentsPerFloor,
                        hint: context.t.common.apartmentsPerFloorHint,
                        icon: Icons.door_front_door_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        required: true,
                        validator: (v) => _validateRange(
                          v,
                          min: _kApartmentsPerFloorMin,
                          max: _kApartmentsPerFloorMax,
                          rangeError:
                              context.t.common.apartmentsPerFloorRangeError,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingL),
                MinimalSectionLabel(title: t.overrideDues),
                const SizedBox(height: AppSizes.spacingXS),
                Text(
                  site?.dueAmount != null
                      ? t.overrideDuesHintWithDefault.replaceAll(
                          '{amount}',
                          site!.dueAmount!.toStringAsFixed(0),
                        )
                      : t.overrideDuesHint,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingS),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _overrideDues,
                  onChanged: _submitting
                      ? null
                      : (v) => setState(() => _overrideDues = v),
                  title: Text(
                    t.overrideDuesSwitch,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_overrideDues) ...[
                  MinimalTextField(
                    controller: _monthlyDuesController,
                    label: context.t.common.monthlyDues,
                    hint: context.t.common.monthlyDuesHint,
                    icon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingFieldSpacing),
                  MinimalPickerField(
                    label: context.t.common.dueDay,
                    value: '$_selectedDueDay',
                    hint: context.t.common.dueDay,
                    icon: Icons.calendar_today_outlined,
                    onTap: _pickDueDay,
                  ),
                ],
                const SizedBox(height: AppSizes.spacingL),
                MinimalSectionLabel(title: t.overrideCollection),
                const SizedBox(height: AppSizes.spacingXS),
                Text(
                  t.overrideCollectionHint,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingS),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _overrideCollection,
                  onChanged: _submitting
                      ? null
                      : (v) => setState(() => _overrideCollection = v),
                  title: Text(
                    t.overrideCollectionSwitch,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_overrideCollection) ...[
                  const SizedBox(height: AppSizes.spacingS),
                  BuildingCollectionFields(
                    manualOnly: true,
                    ibanController: _collectionIbanController,
                    accountTitleController: _collectionAccountTitleController,
                    referenceTemplateController:
                        _collectionReferenceTemplateController,
                  ),
                ],
              ],
            ),
          ),
        ),
=======
                      ),
                      const SizedBox(height: AppSizes.spacingFieldSpacing),
                      MinimalPickerField(
                        label: context.t.common.dueDay,
                        value: '$_selectedDueDay',
                        hint: context.t.common.selectDueDay,
                        icon: Icons.event_outlined,
                        enabled: !_submitting && !_pickingDueDay,
                        onTap: _showDueDayPicker,
                      ),
                    ],
                    const SizedBox(height: AppSizes.spacingFieldSpacing),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        t.overrideCollection,
                        style: ProfileSettingsUi.fieldValue,
                      ),
                      subtitle: Text(
                        t.overrideCollectionHint,
                        style: ProfileSettingsUi.handle,
                      ),
                      value: _overrideCollection,
                      onChanged: (v) =>
                          setState(() => _overrideCollection = v),
                    ),
                    if (_overrideCollection) ...[
                      const SizedBox(height: AppSizes.spacingS),
                      BuildingCollectionFields(
                        ibanController: _collectionIbanController,
                        accountTitleController:
                            _collectionAccountTitleController,
                        referenceTemplateController:
                            _collectionReferenceTemplateController,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      ),
    );
  }

  String? _validateRange(
    String? value, {
    required int min,
    required int max,
    required String rangeError,
  }) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return context.t.common.fieldRequired;
    final n = int.tryParse(raw);
    if (n == null || n < min || n > max) return rangeError;
    return null;
  }

<<<<<<< HEAD
  Future<void> _onSubmit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      double? dueAmount;
      int? dueDay;
      if (_overrideDues) {
        final duesRaw = _monthlyDuesController.text.trim();
        dueAmount = duesRaw.isEmpty ? null : double.tryParse(duesRaw);
        dueDay = _selectedDueDay;
      }

      String? collectionIban;
      String? collectionAccountTitle;
      String? paymentReferenceTemplate;
      if (_overrideCollection) {
        final collection = BuildingCollectionInput.fromControllers(
          iban: _collectionIbanController,
          accountTitle: _collectionAccountTitleController,
          referenceTemplate: _collectionReferenceTemplateController,
        );
        collectionIban = collection?.collectionIban;
        collectionAccountTitle = collection?.collectionAccountTitle;
        paymentReferenceTemplate = collection?.paymentReferenceTemplate;
      }

      await ref.read(siteRepositoryProvider).createSiteBuilding(
            siteId: widget.siteId,
            name: _nameController.text.trim(),
            blockLabel: _blockLabelController.text.trim(),
            addressExtra: _addressExtraController.text.trim(),
            totalFloors: int.parse(_floorsController.text.trim()),
            apartmentsPerFloor:
                int.parse(_apartmentsPerFloorController.text.trim()),
            dueAmount: dueAmount,
            dueDay: dueDay,
            collectionIban: collectionIban,
            collectionAccountTitle: collectionAccountTitle,
            paymentReferenceTemplate: paymentReferenceTemplate,
          );
      await ref.read(buildingsStoreProvider.notifier).refreshBuildings();
      ref.invalidate(siteDetailProvider(widget.siteId));
      ref.invalidate(siteBuildingsProvider(widget.siteId));
      ref.invalidate(standaloneBuildingsProvider);
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            context.t.features.buildings.newBuilding,
=======
  Future<void> _showDueDayPicker() async {
    if (_submitting || _pickingDueDay) return;
    setState(() => _pickingDueDay = true);
    try {
      final picked = await showDueDayPicker(
        context,
        selectedDueDay: _selectedDueDay,
        allowClear: false,
      );
      if (picked != null) {
        setState(() => _selectedDueDay = picked);
      }
    } finally {
      if (mounted) setState(() => _pickingDueDay = false);
    }
  }

  Future<void> _onSubmit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final floors = int.tryParse(_floorsController.text.trim());
    final apartmentsPerFloor =
        int.tryParse(_apartmentsPerFloorController.text.trim());
    if (floors == null || apartmentsPerFloor == null) return;

    double? dueAmount;
    if (_overrideDue) {
      dueAmount = double.tryParse(_monthlyDuesController.text.trim());
      if (dueAmount == null || dueAmount <= 0) {
        ref.read(toastProvider.notifier).show(
              context.t.common.fillRequiredFields,
              type: ToastType.error,
            );
        return;
      }
    }

    BuildingCollectionInput? collection;
    if (_overrideCollection) {
      collection = BuildingCollectionInput.fromControllers(
        iban: _collectionIbanController,
        accountTitle: _collectionAccountTitleController,
        referenceTemplate: _collectionReferenceTemplateController,
      );
    }

    setState(() => _submitting = true);
    try {
      await ref.read(siteRepositoryProvider).createSiteBuilding(
            siteId: widget.siteId,
            blockLabel: _blockLabelController.text.trim(),
            name: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
            addressExtra: _addressExtraController.text.trim().isEmpty
                ? null
                : _addressExtraController.text.trim(),
            totalFloors: floors,
            apartmentsPerFloor: apartmentsPerFloor,
            dueAmount: _overrideDue ? dueAmount : null,
            dueDay: _overrideDue ? _selectedDueDay : null,
            collectionIban: collection?.collectionIban,
            collectionAccountTitle: collection?.collectionAccountTitle,
            paymentReferenceTemplate: collection?.paymentReferenceTemplate,
          );

      if (!mounted) return;
      ref.invalidate(siteDetailProvider(widget.siteId));
      ref.invalidate(siteBuildingsProvider(widget.siteId));
      ref.read(toastProvider.notifier).show(
            context.t.features.sites.blockCreated,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
            type: ToastType.success,
          );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            userFacingError(e),
            type: ToastType.error,
          );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
