import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/show_due_day_picker.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/cities_data.dart';
import '../../../buildings/presentation/widgets/building_collection_fields.dart';
import '../../../buildings/data/buildings_store.dart';
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
                    icon: Icons.domain_outlined,
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
                  MinimalSectionLabel(title: t.defaultDuesSection),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    t.defaultDuesHint,
                    style: AppTypography.body2.copyWith(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  MinimalTextField(
                    controller: _monthlyDuesController,
                    label: context.t.common.monthlyDuesLabel,
                    hint: context.t.common.monthlyDuesHint,
                    icon: Icons.payments_outlined,
                    iconColor: AppColors.warning,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    suffix: Text(
                      '₺',
                      style: ProfileSettingsUi.fieldValue.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

  void _showCityPicker() {
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
    );
  }

  void _showDistrictPicker() {
    final city = _selectedCity;
    if (city == null) return;
    final districts = turkishCities[city] ?? const <String>[];
    PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (ctx) => _SearchablePicker(
        title: context.t.common.selectDistrictTitle,
        items: districts,
        selected: _selectedDistrict,
        onSelected: (district) => setState(() => _selectedDistrict = district),
      ),
    );
  }

  Future<void> _showDueDayPicker() async {
    if (_pickingDueDay) return;
    setState(() => _pickingDueDay = true);
    final day = await showDueDayPicker(context, selectedDueDay: _selectedDueDay);
    if (mounted) {
      setState(() {
        _pickingDueDay = false;
        if (day != null) _selectedDueDay = day;
      });
    }
  }

  Future<void> _onSubmit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    if (_selectedCity == null || _selectedDistrict == null) {
      ref.read(toastProvider.notifier).show(
            context.t.common.fieldRequired,
            type: ToastType.error,
          );
      return;
    }

    setState(() => _submitting = true);
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
    ref.read(toastProvider.notifier).show(
          context.t.features.sites.siteCreated,
          type: ToastType.success,
        );
    context.pop();
  }
}

class _SearchablePicker extends StatefulWidget {
  const _SearchablePicker({
    required this.title,
    required this.items,
    required this.onSelected,
    this.selected,
  });

  final String title;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  State<_SearchablePicker> createState() => _SearchablePickerState();
}

class _SearchablePickerState extends State<_SearchablePicker> {
  late List<String> _filtered;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items.where((e) => e.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBottomSheetScaffold(
      title: widget.title,
      child: Column(
        children: [
          MinimalTextField(
            controller: _searchController,
            label: context.t.common.search,
            hint: context.t.common.search,
            icon: Icons.search,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final item = _filtered[index];
                final selected = item == widget.selected;
                return ListTile(
                  minTileHeight: AppSizes.minTouchTarget,
                  title: Text(
                    item,
                    style: ProfileSettingsUi.fieldValue.copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    widget.onSelected(item);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
