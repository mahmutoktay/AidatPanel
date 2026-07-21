import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locations/location_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/providers/list_cache_refresh.dart';
import '../../../../features/dashboard/domain/entities/dashboard_filter_scope.dart';
import '../../../../features/dashboard/presentation/providers/dashboard_filter_scope_provider.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/form_step_indicator.dart';
import '../../../../shared/widgets/form_wizard_scaffold.dart';
import '../../../../shared/widgets/location_picker_fields.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/show_due_day_picker.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/presentation/widgets/building_collection_fields.dart';
import '../../../dashboard/presentation/widgets/property_type_segmented_tab.dart';
import '../../data/sites_store.dart';

class AddSiteScreen extends ConsumerStatefulWidget {
  const AddSiteScreen({super.key});

  @override
  ConsumerState<AddSiteScreen> createState() => _AddSiteScreenState();
}

class _AddSiteScreenState extends ConsumerState<AddSiteScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _monthlyDuesController = TextEditingController();
  final _collectionIbanController = TextEditingController();
  final _collectionAccountTitleController = TextEditingController();
  final _collectionReferenceTemplateController = TextEditingController();

  int _step = 0;
  Province? _selectedProvince;
  District? _selectedDistrict;
  Neighborhood? _selectedNeighborhood;
  int _selectedDueDay = 1;
  bool _pickingDueDay = false;
  bool _submitting = false;

  static const int _stepCount = 5;

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

  List<FormStepDescriptor> _steps(BuildContext context) {
    final t = context.t.common;
    return [
      FormStepDescriptor(
        label: t.wizardStepSiteName,
        icon: Icons.location_city_outlined,
      ),
      FormStepDescriptor(
        label: t.wizardStepLocation,
        icon: Icons.location_on_outlined,
      ),
      FormStepDescriptor(
        label: t.wizardStepNeighborhoodAddress,
        icon: Icons.home_outlined,
      ),
      FormStepDescriptor(
        label: t.wizardStepDues,
        icon: Icons.payments_outlined,
      ),
      FormStepDescriptor(
        label: t.wizardStepRecipient,
        icon: Icons.account_balance_outlined,
      ),
    ];
  }

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
        if (_nameController.text.trim().isEmpty) {
          ref.read(toastProvider.notifier).show(
                context.t.common.fillRequiredFields,
                type: ToastType.error,
              );
          return false;
        }
        return true;
      case 1:
        if (_selectedProvince == null || _selectedDistrict == null) {
          ref.read(toastProvider.notifier).show(
                context.t.common.selectCityAndDistrict,
                type: ToastType.error,
              );
          return false;
        }
        return true;
      case 2:
        if (_selectedNeighborhood == null ||
            _addressController.text.trim().isEmpty) {
          ref.read(toastProvider.notifier).show(
                context.t.common.fillRequiredFields,
                type: ToastType.error,
              );
          return false;
        }
        return true;
      case 3:
        final dueAmount =
            double.tryParse(_monthlyDuesController.text.trim()) ?? 0;
        if (dueAmount <= 0) {
          ref.read(toastProvider.notifier).show(
                context.t.common.fillRequiredFields,
                type: ToastType.error,
              );
          return false;
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
          '${_addressController.text.trim()}, ${_selectedNeighborhood!.name}, ${_selectedDistrict!.name}';
      final collection = BuildingCollectionInput.fromControllers(
        iban: _collectionIbanController,
        accountTitle: _collectionAccountTitleController,
        referenceTemplate: _collectionReferenceTemplateController,
      );

      final id = await ref.read(sitesStoreProvider.notifier).addSite(
            name: _nameController.text.trim(),
            address: address,
            city: _selectedProvince!.name,
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
      ref.read(dashboardFilterScopeProvider.notifier).update(
            DashboardFilterScope.site(id),
          );
      // Mülkler → Siteler — yeni site listede hemen görünsün.
      invalidateSubscriptionQuota(ref);
      invalidateManagerHomeCaches(ref);
      ref.read(propertyTypeProvider.notifier).update(PropertyType.sites);
      ref.read(managerTabIndexProvider.notifier).update(1);
      context.go('/manager-dashboard');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildStepBody() {
    final t = context.t.features.sites;

    switch (_step) {
      case 0:
        return MinimalTextField(
          controller: _nameController,
          label: t.siteName,
          hint: t.siteNameHint,
          icon: Icons.location_city_outlined,
          required: true,
          autofocus: true,
        );
      case 1:
        return LocationPickerFields(
          selectedProvince: _selectedProvince,
          selectedDistrict: _selectedDistrict,
          onProvinceChanged: (p) => setState(() {
            _selectedProvince = p;
            _selectedDistrict = null;
            _selectedNeighborhood = null;
          }),
          onDistrictChanged: (d) => setState(() {
            _selectedDistrict = d;
            _selectedNeighborhood = null;
          }),
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedProvince != null && _selectedDistrict != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
                child: Text(
                  '${_selectedProvince!.name}, ${_selectedDistrict!.name}',
                  style: ProfileSettingsUi.handle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            LocationPickerFields(
              selectedProvince: _selectedProvince,
              selectedDistrict: _selectedDistrict,
              selectedNeighborhood: _selectedNeighborhood,
              showCity: false,
              showDistrict: false,
              showNeighborhood: true,
              onProvinceChanged: (_) {},
              onDistrictChanged: (_) {},
              onNeighborhoodChanged: (n) =>
                  setState(() => _selectedNeighborhood = n),
            ),
            const SizedBox(height: AppSizes.spacingFieldSpacing),
            MinimalTextField(
              controller: _addressController,
              label: context.t.common.streetAddress,
              hint: context.t.common.streetAddressHint,
              icon: Icons.signpost_outlined,
              required: true,
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
        );
      case 4:
        return BuildingCollectionFields(
          ibanController: _collectionIbanController,
          accountTitleController: _collectionAccountTitleController,
          referenceTemplateController: _collectionReferenceTemplateController,
          showNameLaterHint: true,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;

    return FormWizardScaffold(
      title: t.addSiteTitle,
      steps: _steps(context),
      currentStep: _step,
      stepBody: _buildStepBody(),
      primaryActionLabel:
          _isLastStep ? t.createSite : context.t.common.wizardNext,
      onPrimaryAction: _onPrimaryAction,
      primaryLoading: _submitting,
      absorbing: _submitting,
      onBack: _onBack,
      canPop: _step == 0,
    );
  }
}
