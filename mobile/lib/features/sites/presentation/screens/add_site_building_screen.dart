import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/form_step_indicator.dart';
import '../../../../shared/widgets/form_wizard_scaffold.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/number_grid_selector.dart';
import '../../../../shared/widgets/show_due_day_picker.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/presentation/providers/buildings_cache_refresh.dart';
import '../../../buildings/presentation/widgets/building_collection_fields.dart';
import '../../data/sites_store.dart';

const int _kFloorsMin = 1;
const int _kFloorsMax = 200;
const int _kFloorsQuickMax = 15;
const int _kApartmentsPerFloorMin = 1;
const int _kApartmentsPerFloorMax = 50;
const int _kApartmentsQuickMax = 5;

class AddSiteBuildingScreen extends ConsumerStatefulWidget {
  final String siteId;

  const AddSiteBuildingScreen({super.key, required this.siteId});

  @override
  ConsumerState<AddSiteBuildingScreen> createState() =>
      _AddSiteBuildingScreenState();
}

class _AddSiteBuildingScreenState extends ConsumerState<AddSiteBuildingScreen> {
  final _blockLabelController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressExtraController = TextEditingController();
  final _monthlyDuesController = TextEditingController();
  final _collectionIbanController = TextEditingController();
  final _collectionAccountTitleController = TextEditingController();
  final _collectionReferenceTemplateController = TextEditingController();

  int _step = 0;
  int? _totalFloors;
  int? _apartmentsPerFloor;
  bool _overrideDue = false;
  bool _overrideCollection = false;
  int _selectedDueDay = 1;
  bool _pickingDueDay = false;
  bool _submitting = false;

  static const int _stepCount = 4;

  @override
  void dispose() {
    _blockLabelController.dispose();
    _nameController.dispose();
    _addressExtraController.dispose();
    _monthlyDuesController.dispose();
    _collectionIbanController.dispose();
    _collectionAccountTitleController.dispose();
    _collectionReferenceTemplateController.dispose();
    super.dispose();
  }

  List<FormStepDescriptor> _steps(BuildContext context) {
    final t = context.t.common;
    return [
      FormStepDescriptor(
        label: t.wizardStepBlockInfo,
        icon: Icons.view_module_outlined,
      ),
      FormStepDescriptor(
        label: t.wizardStepFloors,
        icon: Icons.layers_outlined,
      ),
      FormStepDescriptor(
        label: t.wizardStepApartments,
        icon: Icons.door_front_door_outlined,
      ),
      FormStepDescriptor(
        label: t.wizardStepSiteOverrides,
        icon: Icons.tune_outlined,
      ),
    ];
  }

  bool get _isGridStep => _step == 1 || _step == 2;

  bool get _isLastStep => _step == _stepCount - 1;

  void _onBack() {
    if (_step == 0) {
      context.pop();
      return;
    }
    setState(() => _step -= 1);
  }

  void _goNext() {
    if (_step < _stepCount - 1) {
      setState(() => _step += 1);
    }
  }

  bool _validateCurrentStep() {
    switch (_step) {
      case 0:
        if (_blockLabelController.text.trim().isEmpty) {
          ref.read(toastProvider.notifier).show(
                context.t.common.fillRequiredFields,
                type: ToastType.error,
              );
          return false;
        }
        return true;
      case 3:
        if (_overrideDue) {
          final dueAmount =
              double.tryParse(_monthlyDuesController.text.trim()) ?? 0;
          if (dueAmount <= 0) {
            ref.read(toastProvider.notifier).show(
                  context.t.common.fillRequiredFields,
                  type: ToastType.error,
                );
            return false;
          }
        }
        return true;
      default:
        return true;
    }
  }

  void _onPrimaryAction() {
    if (_isLastStep) {
      _onSubmit();
      return;
    }
    if (!_validateCurrentStep()) return;
    _goNext();
  }

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
    if (_totalFloors == null || _apartmentsPerFloor == null) return;
    if (!_validateCurrentStep()) return;

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
            totalFloors: _totalFloors!,
            apartmentsPerFloor: _apartmentsPerFloor!,
            dueAmount: _overrideDue ? dueAmount : null,
            dueDay: _overrideDue ? _selectedDueDay : null,
            collectionIban: collection?.collectionIban,
            collectionAccountTitle: collection?.collectionAccountTitle,
            paymentReferenceTemplate: collection?.paymentReferenceTemplate,
          );

      if (!mounted) return;
      ref.invalidate(siteDetailProvider(widget.siteId));
      ref.invalidate(siteBuildingsProvider(widget.siteId));
      await syncAfterSiteBuildingMutation(ref);
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            context.t.features.sites.blockCreated,
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

  Widget _buildStepBody(String siteName) {
    final t = context.t.features.sites;

    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MinimalSectionLabel(
              title: t.blockSection,
              subtitle: siteName,
            ),
            const SizedBox(height: AppSizes.spacingS),
            MinimalTextField(
              controller: _blockLabelController,
              label: t.blockLabel,
              hint: t.blockLabelHint,
              icon: Icons.view_module_outlined,
              required: true,
              autofocus: true,
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
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.t.common.wizardPickFloorCount,
              style: ProfileSettingsUi.fieldValue.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            NumberGridSelector(
              min: _kFloorsMin,
              maxQuickPick: _kFloorsQuickMax,
              gridColumns: 5,
              manualMax: _kFloorsMax,
              selected: _totalFloors,
              onQuickPick: (value) {
                setState(() => _totalFloors = value);
                _goNext();
              },
              onManualConfirm: (value) {
                setState(() => _totalFloors = value);
                _goNext();
              },
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.t.common.wizardPickApartmentCount,
              style: ProfileSettingsUi.fieldValue.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            NumberGridSelector(
              min: _kApartmentsPerFloorMin,
              maxQuickPick: _kApartmentsQuickMax,
              gridColumns: 5,
              manualMax: _kApartmentsPerFloorMax,
              selected: _apartmentsPerFloor,
              onQuickPick: (value) {
                setState(() => _apartmentsPerFloor = value);
                _goNext();
              },
              onManualConfirm: (value) {
                setState(() => _apartmentsPerFloor = value);
                _goNext();
              },
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              const SizedBox(height: AppSizes.spacingS),
              MinimalTextField(
                controller: _monthlyDuesController,
                label: context.t.common.monthlyDuesLabel,
                hint: context.t.common.monthlyDuesHint,
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              onChanged: (v) => setState(() => _overrideCollection = v),
            ),
            if (_overrideCollection) ...[
              const SizedBox(height: AppSizes.spacingS),
              BuildingCollectionFields(
                ibanController: _collectionIbanController,
                accountTitleController: _collectionAccountTitleController,
                referenceTemplateController:
                    _collectionReferenceTemplateController,
                showNameLaterHint: true,
              ),
            ],
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final siteAsync = ref.watch(siteDetailProvider(widget.siteId));

    return siteAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(t.addBlockTitle),
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: AppBackButton(onPressed: () => context.pop()),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: Text(t.addBlockTitle),
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: AppBackButton(onPressed: () => context.pop()),
          ),
        ),
        body: Center(child: Text(userFacingError(e))),
      ),
      data: (detail) => FormWizardScaffold(
        title: t.addBlockTitle,
        steps: _steps(context),
        currentStep: _step,
        stepBody: _buildStepBody(detail.site.name),
        primaryActionLabel:
            _isLastStep ? t.createBlock : context.t.common.wizardNext,
        onPrimaryAction: _onPrimaryAction,
        primaryLoading: _submitting,
        showStepActions: !_isGridStep,
        absorbing: _submitting,
        onBack: _onBack,
        canPop: _step == 0,
      ),
    );
  }
}
