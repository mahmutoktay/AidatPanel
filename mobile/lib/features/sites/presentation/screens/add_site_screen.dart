import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
<<<<<<< HEAD
import '../../../../core/theme/app_typography.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/searchable_location_picker.dart';
import '../../../../shared/widgets/show_due_day_picker.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/turkish_locations.dart';
import '../../../buildings/presentation/widgets/building_collection_fields.dart';
import '../../../buildings/data/buildings_store.dart';
=======
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/show_due_day_picker.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/cities_data.dart';
import '../../../buildings/presentation/widgets/building_collection_fields.dart';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
import '../../data/sites_store.dart';

class AddSiteScreen extends ConsumerStatefulWidget {
  const AddSiteScreen({super.key});

  @override
  ConsumerState<AddSiteScreen> createState() => _AddSiteScreenState();
}

class _AddSiteScreenState extends ConsumerState<AddSiteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
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
<<<<<<< HEAD
  void initState() {
    super.initState();
    TurkishLocations.ensureLoaded();
  }

  @override
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _monthlyDuesController.dispose();
    _collectionIbanController.dispose();
    _collectionAccountTitleController.dispose();
    _collectionReferenceTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;

<<<<<<< HEAD
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
          title: Text(t.addSite, style: ProfileSettingsUi.title),
        ),
        bottomNavigationBar: MinimalStickyActionBar(
          label: t.createSite,
          loading: _submitting,
          onPressed: _onSubmit,
        ),
        body: SafeArea(
=======
    return DashboardSecondaryScaffold(
      title: t.addSiteTitle,
      canPop: !_submitting,
      useMinimalBackButton: true,
      onBack: _submitting ? null : () => context.pop(),
      bottomNavigationBar: MinimalStickyActionBar(
        label: t.createSite,
        loading: _submitting,
        onPressed: _onSubmit,
      ),
      body: SafeArea(
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
                    label: t.siteName,
                    hint: t.siteNameHint,
<<<<<<< HEAD
                    icon: Icons.domain_outlined,
=======
                    icon: Icons.location_city_outlined,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
                  MinimalSectionLabel(title: t.defaultDuesSection),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    t.defaultDuesHint,
                    style: AppTypography.body2.copyWith(color: AppColors.mutedText),
                  ),
=======
                  MinimalSectionLabel(title: context.t.common.details),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
                  const SizedBox(height: AppSizes.spacingS),
                  MinimalTextField(
                    controller: _monthlyDuesController,
                    label: context.t.common.monthlyDuesLabel,
                    hint: context.t.common.monthlyDuesHint,
                    icon: Icons.payments_outlined,
                    iconColor: AppColors.warning,
<<<<<<< HEAD
=======
                    required: true,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    suffix: Text(
                      '₺',
                      style: ProfileSettingsUi.fieldValue.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
<<<<<<< HEAD
=======
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.t.common.fieldRequired
                        : null,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
        ),
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      ),
    );
  }

  void _showCityPicker() {
<<<<<<< HEAD
    SearchableLocationPicker.showCityPicker(
      context,
      selected: _selectedCity,
      onSelected: (city) {
        setState(() {
          _selectedCity = city;
          _selectedDistrict = null;
        });
      },
=======
    PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (ctx) => _SearchablePicker(
        title: context.t.common.selectCityTitle,
        items: sortedCityNames,
        selected: _selectedCity,
        onSelected: (city) {
          setState(() {
            _selectedCity = city;
            _selectedDistrict = null;
          });
        },
      ),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    );
  }

  void _showDistrictPicker() {
<<<<<<< HEAD
    final city = _selectedCity;
    if (city == null) return;
    SearchableLocationPicker.showDistrictPicker(
      context,
      city: city,
      selected: _selectedDistrict,
      onSelected: (district) => setState(() => _selectedDistrict = district),
=======
    final districts = turkishCities[_selectedCity] ?? const [];
    PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (ctx) => _SearchablePicker(
        title: context.t.common.selectDistrictTitle,
        items: districts,
        selected: _selectedDistrict,
        onSelected: (district) {
          setState(() => _selectedDistrict = district);
        },
      ),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    );
  }

  Future<void> _showDueDayPicker() async {
<<<<<<< HEAD
    if (_pickingDueDay) return;
    setState(() => _pickingDueDay = true);
    final day = await showDueDayPicker(context, selectedDueDay: _selectedDueDay);
    if (mounted) {
      setState(() {
        _pickingDueDay = false;
        if (day != null) _selectedDueDay = day;
      });
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
  }

  Future<void> _onSubmit() async {
<<<<<<< HEAD
    if (_submitting || !_formKey.currentState!.validate()) return;
    if (_selectedCity == null || _selectedDistrict == null) {
      ref.read(toastProvider.notifier).show(
            context.t.common.fieldRequired,
=======
    if (_submitting) return;

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) {
      ref.read(toastProvider.notifier).show(
            context.t.common.fillRequiredFields,
            type: ToastType.error,
          );
      return;
    }
    if (_selectedCity == null || _selectedDistrict == null) {
      ref.read(toastProvider.notifier).show(
            context.t.common.selectCityAndDistrict,
            type: ToastType.error,
          );
      return;
    }

    final dueAmount =
        double.tryParse(_monthlyDuesController.text.trim()) ?? 0;
    if (dueAmount <= 0) {
      ref.read(toastProvider.notifier).show(
            context.t.common.fillRequiredFields,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
            type: ToastType.error,
          );
      return;
    }

    setState(() => _submitting = true);
<<<<<<< HEAD
    final duesRaw = _monthlyDuesController.text.trim();
    final dueAmount = duesRaw.isEmpty ? null : double.tryParse(duesRaw);

    final error = await ref.read(sitesStoreProvider.notifier).addSite(
          name: _nameController.text.trim(),
          address:
              '${_addressController.text.trim()}, $_selectedDistrict',
          city: _selectedCity!,
          dueAmount: dueAmount,
          dueDay: _selectedDueDay,
          collectionIban: _collectionIbanController.text.trim(),
          collectionAccountTitle:
              _collectionAccountTitleController.text.trim(),
          paymentReferenceTemplate:
              _collectionReferenceTemplateController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error != null) {
      ref.read(toastProvider.notifier).show(error, type: ToastType.error);
      return;
    }

    await ref.read(buildingsStoreProvider.notifier).refreshBuildings();
    if (!mounted) return;
    ref.read(toastProvider.notifier).show(
          context.t.features.sites.siteCreated,
          type: ToastType.success,
        );
    context.pop();
=======
    try {
      final address =
          '${_addressController.text.trim()}, $_selectedDistrict';
      final collection = BuildingCollectionInput.fromControllers(
        iban: _collectionIbanController,
        accountTitle: _collectionAccountTitleController,
        referenceTemplate: _collectionReferenceTemplateController,
      );

      final id = await ref.read(sitesStoreProvider.notifier).addSite(
            name: _nameController.text.trim(),
            address: address,
            city: _selectedCity!,
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
              context.t.features.sites.siteCreateFailed,
              type: ToastType.error,
            );
        return;
      }

      ref.read(toastProvider.notifier).show(
            context.t.features.sites.siteCreated,
            type: ToastType.success,
          );
      context.pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _SearchablePicker extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _SearchablePicker({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_SearchablePicker> createState() => _SearchablePickerState();
}

class _SearchablePickerState extends State<_SearchablePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((s) => s.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
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
              AppSizes.dashboardScreenPaddingHorizontal,
              AppSizes.spacingM,
              AppSizes.dashboardScreenPaddingHorizontal,
              AppSizes.spacingS,
            ),
            child: Text(widget.title, style: ProfileSettingsUi.title),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.dashboardScreenPaddingHorizontal,
            ),
            child: MinimalSearchField(
              hint: context.t.common.search,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      context.t.common.noResults,
                      style: ProfileSettingsUi.handle,
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.dashboardScreenPaddingHorizontal,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final item = filtered[index];
                      final isSelected = item == widget.selected;
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSizes.spacingXS,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              widget.onSelected(item);
                              context.pop();
                            },
                            borderRadius: BorderRadius.circular(
                              ProfileSettingsUi.fieldRadius,
                            ),
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: AppSizes.minTouchTarget,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.spacingM,
                                vertical: AppSizes.spacingS,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? ProfileSettingsUi.background
                                    : ProfileSettingsUi.fieldFill,
                                borderRadius: BorderRadius.circular(
                                  ProfileSettingsUi.fieldRadius,
                                ),
                                border: isSelected
                                    ? Border.all(
                                        color: ProfileSettingsUi.ink,
                                        width: ProfileSettingsUi
                                            .fieldFocusBorderWidth,
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: ProfileSettingsUi.fieldValue
                                          .copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_rounded,
                                      color: AppColors.statusGreen,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  }
}
