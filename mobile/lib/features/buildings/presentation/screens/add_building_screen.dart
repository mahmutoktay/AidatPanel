import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/searchable_location_picker.dart';
import '../../../../shared/widgets/show_due_day_picker.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/buildings_store.dart';
import '../../data/turkish_locations.dart';
import '../widgets/building_collection_fields.dart';

/// Backend `buildingService.createBuildingService` Zod aralıkları (Tur 5 §10/2):
///  - totalFloors: 1..200
///  - apartmentsPerFloor: 1..50
const int _kFloorsMin = 1;
const int _kFloorsMax = 200;
const int _kApartmentsPerFloorMin = 1;
const int _kApartmentsPerFloorMax = 50;

class AddBuildingScreen extends ConsumerStatefulWidget {
  const AddBuildingScreen({super.key});

  @override
  ConsumerState<AddBuildingScreen> createState() => _AddBuildingScreenState();
}

class _AddBuildingScreenState extends ConsumerState<AddBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _floorsController = TextEditingController();
  final _apartmentsPerFloorController = TextEditingController();
  final _monthlyDuesController = TextEditingController();
  final _collectionIbanController = TextEditingController();
  final _collectionAccountTitleController = TextEditingController();
  final _collectionReferenceTemplateController = TextEditingController();

  String? _selectedCity;
  String? _selectedDistrict;
  int _selectedDueDay = 1;
  bool _pickingDueDay = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    TurkishLocations.ensureLoaded();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
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
          title: Text(
            context.t.common.addBuildingNew,
            style: ProfileSettingsUi.title,
          ),
        ),
        bottomNavigationBar: MinimalStickyActionBar(
          label: context.t.common.createBuilding,
          loading: _submitting,
          onPressed: _onSubmit,
        ),
        body: SafeArea(
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
                  MinimalSectionLabel(title: context.t.common.basicInfo),
                  const SizedBox(height: AppSizes.spacingS),
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
                  MinimalSectionLabel(title: context.t.common.location),
                  const SizedBox(height: AppSizes.spacingS),
                  MinimalPickerField(
                    label: context.t.common.cityRequired.replaceAll(' *', ''),
                    value: _selectedCity,
                    hint: context.t.common.selectCity,
                    icon: Icons.location_on_outlined,
                    iconColor: AppColors.info,
                    required: true,
                    onTap: _showCityPicker,
                  ),
                  const SizedBox(height: AppSizes.spacingFieldSpacing),
                  MinimalPickerField(
                    label:
                        context.t.common.districtRequired.replaceAll(' *', ''),
                    value: _selectedDistrict,
                    hint: _selectedCity != null
                        ? context.t.common.selectDistrict
                        : context.t.common.selectCityFirst,
                    icon: Icons.map_outlined,
                    required: true,
                    enabled: _selectedCity != null,
                    onTap: _selectedCity != null ? _showDistrictPicker : null,
                  ),
                  const SizedBox(height: AppSizes.spacingFieldSpacing),
                  MinimalTextField(
                    controller: _addressController,
                    label: context.t.common.streetAddress,
                    hint: context.t.common.streetAddressHint,
                    icon: Icons.home_outlined,
                    required: true,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.t.common.fieldRequired
                        : null,
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
                            iconColor: AppColors.statusBlue,
                            required: true,
                            labelMinLines: 2,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
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
                            iconColor: AppColors.statusGreen,
                            required: true,
                            labelMinLines: 2,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
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
                  ),
                  const SizedBox(height: AppSizes.spacingFieldSpacing),
                  MinimalTextField(
                    controller: _monthlyDuesController,
                    label: context.t.common.monthlyDuesLabel,
                    hint: context.t.common.monthlyDuesHint,
                    icon: Icons.payments_outlined,
                    iconColor: AppColors.warning,
                    required: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    suffix: Text(
                      '₺',
                      style: ProfileSettingsUi.fieldValue.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.t.common.fieldRequired
                        : null,
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
                  const SizedBox(height: AppSizes.spacingFieldSpacing),
                  BuildingCollectionFields(
                    ibanController: _collectionIbanController,
                    accountTitleController: _collectionAccountTitleController,
                    referenceTemplateController:
                        _collectionReferenceTemplateController,
                  ),
                ],
              ),
            ),
          ),
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

  void _showCityPicker() {
    SearchableLocationPicker.showCityPicker(
      context,
      selected: _selectedCity,
      onSelected: (city) {
        setState(() {
          _selectedCity = city;
          _selectedDistrict = null;
        });
      },
    );
  }

  void _showDistrictPicker() {
    final city = _selectedCity;
    if (city == null) return;
    SearchableLocationPicker.showDistrictPicker(
      context,
      city: city,
      selected: _selectedDistrict,
      onSelected: (district) {
        setState(() => _selectedDistrict = district);
      },
    );
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

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) {
      ref
          .read(toastProvider.notifier)
          .show(context.t.common.fillRequiredFields, type: ToastType.error);
      return;
    }
    if (_selectedCity == null || _selectedDistrict == null) {
      ref
          .read(toastProvider.notifier)
          .show(context.t.common.selectCityAndDistrict, type: ToastType.error);
      return;
    }

    final floors = int.tryParse(_floorsController.text.trim()) ?? 0;
    final apartmentsPerFloor =
        int.tryParse(_apartmentsPerFloorController.text.trim()) ?? 0;
    final dueAmount =
        double.tryParse(_monthlyDuesController.text.trim()) ?? 0;

    if (dueAmount <= 0) {
      ref.read(toastProvider.notifier).show(
            context.t.common.fillRequiredFields,
            type: ToastType.error,
          );
      return;
    }

    setState(() => _submitting = true);
    try {
      final address =
          '${_addressController.text.trim()}, $_selectedDistrict';

      final collection = BuildingCollectionInput.fromControllers(
        iban: _collectionIbanController,
        accountTitle: _collectionAccountTitleController,
        referenceTemplate: _collectionReferenceTemplateController,
      );

      final id = await ref.read(buildingsStoreProvider.notifier).addBuilding(
            name: _nameController.text.trim(),
            address: address,
            city: _selectedCity!,
            totalFloors: floors,
            apartmentsPerFloor: apartmentsPerFloor,
            dueAmount: dueAmount,
            dueDay: _selectedDueDay,
            currency: 'TRY',
            collectionIban: collection?.collectionIban,
            collectionAccountTitle: collection?.collectionAccountTitle,
            paymentReferenceTemplate: collection?.paymentReferenceTemplate,
          );

      if (!mounted) return;
      if (id == null) {
        ref.read(toastProvider.notifier).show(
              context.t.common.buildingAddFailed,
              type: ToastType.error,
            );
        return;
      }

      ref
          .read(toastProvider.notifier)
          .show(context.t.common.buildingAddedSuccess, type: ToastType.success);
      context.pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
