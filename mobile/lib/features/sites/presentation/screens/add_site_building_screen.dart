import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/show_due_day_picker.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/presentation/widgets/building_collection_fields.dart';
import '../../data/sites_store.dart';

const int _kFloorsMin = 1;
const int _kFloorsMax = 200;
const int _kApartmentsPerFloorMin = 1;
const int _kApartmentsPerFloorMax = 50;

class AddSiteBuildingScreen extends ConsumerStatefulWidget {
  final String siteId;

  const AddSiteBuildingScreen({super.key, required this.siteId});

  @override
  ConsumerState<AddSiteBuildingScreen> createState() =>
      _AddSiteBuildingScreenState();
}

class _AddSiteBuildingScreenState extends ConsumerState<AddSiteBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _blockLabelController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressExtraController = TextEditingController();
  final _floorsController = TextEditingController();
  final _apartmentsPerFloorController = TextEditingController();
  final _monthlyDuesController = TextEditingController();
  final _collectionIbanController = TextEditingController();
  final _collectionAccountTitleController = TextEditingController();
  final _collectionReferenceTemplateController = TextEditingController();

  bool _overrideDue = false;
  bool _overrideCollection = false;
  int _selectedDueDay = 1;
  bool _pickingDueDay = false;
  bool _submitting = false;

  @override
  void dispose() {
    _blockLabelController.dispose();
    _nameController.dispose();
    _addressExtraController.dispose();
    _floorsController.dispose();
    _apartmentsPerFloorController.dispose();
    _monthlyDuesController.dispose();
    _collectionIbanController.dispose();
    _collectionAccountTitleController.dispose();
    _collectionReferenceTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final siteAsync = ref.watch(siteDetailProvider(widget.siteId));

    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleSpacing: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: MinimalBackButton(
              onPressed: _submitting ? null : () => context.pop(),
            ),
          ),
          title: Text(t.addBlockTitle, style: ProfileSettingsUi.title),
        ),
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
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
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
        ),
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
